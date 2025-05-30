require 'faker'

puts "🔗 Creating movement quotes"

movement_quote_count = 0

categories = [
  "Historical Context", "Musical Analysis", "Performance Notes", "Biographical Reference",
  "Theoretical Discussion", "Critical Review", "Cultural Background", "Technical Analysis"
]

score_locations = [
  "mm. 1-8", "mm. 25-32", "Development section", "Recapitulation",
  "Coda", "Bridge passage", "Second theme", "Opening theme",
  "Climax", "Final measures", "Transition", "Exposition"
]

Movement.includes(:work).find_each do |movement|
  # Each movement gets 0-3 quotes
  quotes_count = rand(0..3)

  # Get random quotes for this movement
  available_quotes = Quote.order("RANDOM()").limit(quotes_count)

  available_quotes.each do |quote|
    MovementQuote.create!(
      quote: quote,
      movement: movement,
      category: categories.sample,
      location_in_score: score_locations.sample,
      excerpt_text: Faker::Lorem.sentence(word_count: 12),
      notes: Faker::Lorem.paragraph(sentence_count: 3)
    )
    movement_quote_count += 1
  end

  if quotes_count > 0
    puts "-- Created #{quotes_count} quotes for movement '#{movement.title}' from '#{movement.work.title}'"
  end
end

puts "✅ Created #{MovementQuote.count} movement quotes in total"
