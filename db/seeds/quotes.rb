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

  Quote.create!(
    title: title,
    author: author,
    notes: Faker::Lorem.paragraph(sentence_count: 6, supplemental: true, random_sentences_to_add: 2)
  )
  quote_count += 1
  puts "-- Created quote #{quote_count}/#{total_quote_count}: '#{Quote.last.title}' by #{Quote.last.author}"
end

puts "✅ Created #{Quote.count} quotes in total"
