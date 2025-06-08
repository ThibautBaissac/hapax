require 'faker'

puts "🎶 Creating movements"

movement_count = 0

movement_tempo_markings = [
  "Allegro", "Andante", "Adagio", "Presto", "Largo", "Moderato", "Vivace",
  "Allegretto", "Andantino", "Grave", "Prestissimo", "Lento"
]

movement_forms = [
  "Sonata Form", "Rondo", "Theme and Variations", "Minuet and Trio",
  "Scherzo", "Fugue", "ABA Form", "Through-composed"
]

Work.find_each do |work|
  # Skip the special Prokofiev "Sarcasms" work - it should have quotes instead of movements
  next if work.title == "Sarcasms" && work.composer.last_name == "Prokofiev"

  # Randomly skip 30% of works so they can potentially have quotes instead
  # This ensures some works remain available for quotes according to business rules
  next if rand < 0.3

  movements_count = rand(1..4) # Most works have 1-4 movements

  movements_count.times do |position|
    tempo = movement_tempo_markings.sample

    title_options = [
      "#{position + 1}. #{tempo}",
      "#{position + 1}. #{tempo} #{movement_forms.sample}",
      "Movement #{position + 1}",
      "#{tempo} in #{["C major", "D minor", "E flat major", "F sharp minor"].sample}"
    ]

    Movement.create!(
      title: title_options.sample,
      work: work,
      position: position + 1,
      duration: rand(120..1200), # 2 minutes to 20 minutes in seconds
      description: Faker::Lorem.paragraph(sentence_count: 3)
    )
    movement_count += 1
  end

  puts "-- Created #{movements_count} movements for '#{work.title}'"
end

puts "✅ Created #{Movement.count} movements in total"
