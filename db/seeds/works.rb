require 'faker'

puts "🎵 Creating works"

work_count = 0
total_work_count = 50

work_types = [
  "Symphony", "Concerto", "Sonata", "Quartet", "Quintet", "Suite", "Prelude",
  "Fugue", "Etude", "Nocturne", "Waltz", "March", "Overture", "Fantasy"
]

instruments = [
  "Piano", "Violin", "Cello", "Flute", "Clarinet", "Orchestra", "String Quartet",
  "Organ", "Harpsichord", "Oboe", "Horn", "Trumpet"
]

Composer.find_each do |composer|
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
    puts "-- Created work #{work_count}: #{Work.last.title} by #{composer.fullname}"
  end
end

puts "✅ Created #{Work.count} works in total"
