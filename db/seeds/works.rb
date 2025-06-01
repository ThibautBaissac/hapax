require 'faker'

puts "🎵 Creating works"

work_count = 0
total_work_count = 50

work_types = [
  "Piece",
  "Fugue",
  "Cantata",
  "Opera",
  "Oratorio",
  "Mass",
  "Suite",
  "Symphony",
  "Sonata",
  "Trio",
  "Quartet",
  "Quintet",
  "Sextet",
  "Septet",
  "Concerto",
  "Song Cycle",
  "Prelude",
  "Etude",
  "Nocturne",
  "Lied",
  "Ballade",
  "Variation"
]

instruments = [
  "Piano", "Violin", "Cello", "Flute", "Clarinet", "Orchestra", "String Quartet",
  "Organ", "Harpsichord", "Oboe", "Horn", "Trumpet"
]

# Greif
composer = Composer.find_by(last_name: "Greif")
Work.create!(
  composer:,
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

Composer.find_each do |composer|
  next if composer.last_name.downcase == "greif"
  works_for_composer = rand(2..5)

  works_for_composer.times do |i|
    work_type = work_types.sample
    instrument = instruments.sample
    number = rand(1..20)
    key = ["C major", "D minor", "E flat major", "F sharp minor", "G major", "A minor", "B flat major"].sample

    title_options = [
      "#{work_type} No. #{number} in #{key}",
      "#{work_type} for #{instrument}",
      "#{work_type} No. #{number}",
      "#{Faker::Ancient.god} #{work_type}",
      "#{work_type} '#{Faker::Music.album}'"
    ]

    Work.create!(
      opus: "Op. #{rand(1..200)}#{['', 'a', 'b'].sample}",
      title: title_options.sample,
      description: Faker::Lorem.paragraph(sentence_count: 4),
      duration: rand(300..3600), # 5 minutes to 1 hour in seconds
      composer: composer
    )
    work_count += 1
    puts "-- Created work #{work_count}: #{Work.last.title} by #{composer.full_name}"
  end
end

puts "✅ Created #{Work.count} works in total"
