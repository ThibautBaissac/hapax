require 'faker'

puts "🎵 Creating PROKOFIEV works"

prokofiev = Composer.find_by(last_name: "Prokofiev")

prokofiev.works.create!(
  composer: prokofiev,
  opus: "Op. 25",
  title: "Sarcasms",
  description: "Five pieces for piano, each marked with a sarcastic character. These miniatures showcase Prokofiev's wit and harmonic innovation in concentrated form.",
  duration: 720, # 12 minutes
  instrumentation: "Piano",
  recorded: true,
  form: :piece,
  structure: :movement,
  start_date_composed: Date.new(1912, 1, 1),
  end_date_composed: Date.new(1914, 12, 31),
  unsure_start_date: false,
  unsure_end_date: false
)

puts "✅ Created #{prokofiev.works.count} works in total"
