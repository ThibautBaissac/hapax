require 'faker'

puts "📚 Creating quotes"

quote_count = 0
total_quote_count = 30

# Mix of academic and popular sources
source_types = [
  { type: "Academic Journal", author_format: :academic },
  { type: "Book", author_format: :author },
  { type: "Magazine Article", author_format: :journalist },
  { type: "Encyclopedia Entry", author_format: :academic },
  { type: "Biography", author_format: :author },
  { type: "Music Review", author_format: :critic }
]

academic_titles = [
  "The Harmonic Structure of #{Faker::Music.genre} Music",
  "Compositional Techniques in the #{rand(17..20)}th Century",
  "Performance Practice and Historical Context",
  "Analysis of Motivic Development in Classical Forms",
  "The Evolution of Musical Expression",
  "Theoretical Approaches to Musical Interpretation"
]

book_titles = [
  "The Life and Works of Great Composers",
  "Understanding Classical Music: A Complete Guide",
  "The Art of Musical Performance",
  "Masterpieces of Western Music",
  "The Classical Music Encyclopedia",
  "Great Composers and Their Times"
]

# Analyze available associations based on business rules
composer = Composer.find_by(last_name: "Prokofiev")
all_works = composer.works.includes(:movements, :quote_details).to_a
all_movements = all_works.flat_map(&:movements)

# Business rules:
# 1. Works can have quotes ONLY if they don't have movements
# 2. Movements can always have quotes
# 3. Works cannot have both movements and quotes

# Find works that can accept quotes (no movements)
works_for_quotes = all_works.select { |w| w.movements.empty? }

# All movements can accept quotes
movements_for_quotes = all_movements

puts "Analysis of available associations:"
puts "- #{all_works.count} total works"
puts "- #{works_for_quotes.count} works available for quotes (no movements)"
puts "- #{all_movements.count} movements available for quotes"
puts "- Total potential quote targets: #{works_for_quotes.count + movements_for_quotes.count}"

# Exit early if no valid targets
if works_for_quotes.empty? && movements_for_quotes.empty?
  puts "⚠️  No valid targets for quotes found. Skipping quote creation."
  return
end

categories = ["Main Theme", "Development", "Recapitulation", "Coda", "Introduction", "Bridge", "Climax", "Transition"]

# Ensure Prokofiev's "Sarcasms" work gets at least 2 quotes
prokofiev_sarcasms = Work.joins(:composer).find_by(title: "Sarcasms", composers: { last_name: "Prokofiev" })
if prokofiev_sarcasms && prokofiev_sarcasms.can_add_quotes?
  puts "Creating guaranteed quotes for Prokofiev's Sarcasms..."

  2.times do |i|
    source = source_types.sample
    case source[:author_format]
    when :academic
      author = "#{Faker::Name.last_name}, #{Faker::Name.first_name[0]}."
      title = academic_titles.sample
    when :author
      author = "#{Faker::Name.first_name} #{Faker::Name.last_name}"
      title = book_titles.sample
    when :journalist, :critic
      author = "#{Faker::Name.first_name} #{Faker::Name.last_name}"
      title = "#{Faker::Lorem.sentence(word_count: 8).chomp('.')}: A Critical Analysis"
    end

    quote = Quote.create!(
      title: title,
      author: author,
      notes: Faker::Lorem.paragraph(sentence_count: 6, supplemental: true, random_sentences_to_add: 2)
    )

    QuoteDetail.create!(
      quote: quote,
      detailable: prokofiev_sarcasms,
      category: categories.sample,
      location: "Piece #{i + 1}, mm. #{rand(1..50)}-#{rand(51..100)}",
      excerpt_text: "Prokofiev's harmonic #{['irony', 'wit', 'sarcasm', 'innovation'].sample} is evident in this passage",
      notes: "Analysis of Prokofiev's characteristic style and harmonic language in the Sarcasms."
    )

    puts "  -- Created guaranteed quote #{i + 1} for Prokofiev's Sarcasms"
  end

  # Reduce total_quote_count by 2 since we already created 2
  total_quote_count -= 2
end

(total_quote_count).times do
  source = source_types.sample

  case source[:author_format]
  when :academic
    author = "#{Faker::Name.last_name}, #{Faker::Name.first_name[0]}."
    title = academic_titles.sample
  when :author
    author = "#{Faker::Name.first_name} #{Faker::Name.last_name}"
    title = book_titles.sample
  when :journalist, :critic
    author = "#{Faker::Name.first_name} #{Faker::Name.last_name}"
    title = "#{Faker::Lorem.sentence(word_count: 8).chomp('.')}: A Critical Analysis"
  end

  quote = Quote.create!(
    title: title,
    author: author,
    notes: Faker::Lorem.paragraph(sentence_count: 6, supplemental: true, random_sentences_to_add: 2)
  )

  quote_count += 1
  puts "-- Created quote #{quote_count}/#{total_quote_count}: '#{quote.title}' by #{quote.author}"

  # Determine association strategy based on available targets
  all_targets = []

  # Add eligible works (70% weight for more work-level quotes since they're rarer)
  works_for_quotes.each { |work| 7.times { all_targets << { type: :work, target: work } } }

  # Add all movements (30% weight)
  movements_for_quotes.each { |movement| 3.times { all_targets << { type: :movement, target: movement } } }

  if all_targets.any?
    selected_target = all_targets.sample
    detailable = selected_target[:target]

    begin
      case selected_target[:type]
      when :work
        # Double-check the work can still accept quotes (in case of concurrent modifications)
        if detailable.can_add_quotes?
          puts "   -> Associating with work: #{detailable.title}"
          location_type = "Work"
        else
          puts "   ⚠️  Work #{detailable.title} can no longer accept quotes, skipping"
          next
        end
      when :movement
        puts "   -> Associating with movement: #{detailable.title} (#{detailable.work.title})"
        location_type = "Movement"
      end

      # Create QuoteDetail with realistic musical data
      QuoteDetail.create!(
        quote: quote,
        detailable: detailable,
        category: categories.sample,
        location: "mm. #{rand(1..200)}-#{rand(201..400)}",
        excerpt_text: Faker::Lorem.sentence(word_count: rand(3..8)),
        notes: Faker::Lorem.paragraph(sentence_count: rand(1..3))
      )

      puts "   ✅ Created QuoteDetail association with #{location_type}"

    rescue ActiveRecord::RecordInvalid => e
      puts "   ⚠️  Failed to create association: #{e.message}"
      puts "   ℹ️  This might be due to validation rules - the target may have become invalid"
    end
  else
    puts "   -> No valid targets available for association"
  end
end

puts "✅ Created #{Quote.count} quotes and #{QuoteDetail.count} quote details in total"
