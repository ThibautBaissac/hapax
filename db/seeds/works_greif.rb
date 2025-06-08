require 'faker'

puts "🎵 Creating GREIF works"

greif = Composer.find_by(last_name: "Greif")

greif.works.create!(
  opus: "Op. 270/271",
  title: "Hölderlin Lieder",
  description: Faker::Lorem.paragraph(sentence_count: 4),
  duration: 5400,
  instrumentation: "Voice, Piano",
  recorded: false,
  form: :song_cycle,
  structure: :lied,
  start_date_composed: Date.new(1990, 12, 21),
  end_date_composed: Date.new(1992, 01, 01),
  unsure_start_date: false,
  unsure_end_date: true
)


puts "✅ Created #{greif.works.count} works in total"
