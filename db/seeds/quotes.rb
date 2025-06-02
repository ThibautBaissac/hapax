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

# Get available works and movements for associations
available_works = Work.all.to_a
available_movements = Movement.all.to_a

puts "Found #{available_works.count} works and #{available_movements.count} movements for associations"

categories = ["Main Theme", "Development", "Recapitulation", "Coda", "Introduction", "Bridge", "Climax", "Transition"]

total_quote_count.times do
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

  # Randomly decide whether to associate with work or movement (if available)
  if available_works.any? || available_movements.any?
    # 60% chance to associate with movement, 40% with work (if available)
    associate_with_movement = available_movements.any? && (available_works.empty? || rand < 0.6)

    begin
      if associate_with_movement
        movement = available_movements.sample
        detailable = movement
        location_type = "Movement"
        puts "   -> Associating with movement: #{movement.title} (#{movement.work.title})"
      else
        # Only associate with works that don't have movements (to avoid validation errors)
        works_without_movements = available_works.select { |w| w.movements.empty? }

        if works_without_movements.any?
          work = works_without_movements.sample
          detailable = work
          location_type = "Work"
          puts "   -> Associating with work: #{work.title}"
        else
          # If no works without movements, pick a random movement instead
          if available_movements.any?
            movement = available_movements.sample
            detailable = movement
            location_type = "Movement"
            puts "   -> Associating with movement (fallback): #{movement.title} (#{movement.work.title})"
          else
            puts "   -> No valid associations available, skipping"
            next
          end
        end
      end

      # Create QuoteDetail with random data
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
    end
  else
    puts "   -> No works or movements available for association"
  end
end

puts "✅ Created #{Quote.count} quotes and #{QuoteDetail.count} quote details in total"
