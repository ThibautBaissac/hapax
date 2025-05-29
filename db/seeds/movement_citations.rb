require 'faker'

puts "🔗 Creating movement citations"

movement_citation_count = 0

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
  # Each movement gets 0-3 citations
  citations_count = rand(0..3)

  # Get random citations for this movement
  available_citations = Citation.order("RANDOM()").limit(citations_count)

  available_citations.each do |citation|
    MovementCitation.create!(
      citation: citation,
      movement: movement,
      category: categories.sample,
      location_in_score: score_locations.sample,
      excerpt_text: Faker::Lorem.sentence(word_count: 12),
      notes: Faker::Lorem.paragraph(sentence_count: 3)
    )
    movement_citation_count += 1
  end

  if citations_count > 0
    puts "-- Created #{citations_count} citations for movement '#{movement.title}' from '#{movement.work.title}'"
  end
end

puts "✅ Created #{MovementCitation.count} movement citations in total"
