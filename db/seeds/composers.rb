require 'faker'

puts "🎼 Creating composers"

composer_count = 0

composers = [
  { first_name: "Olivier", last_name: "Greif", birth_date: Date.new(1950, 1, 3), death_date: Date.new(2000, 5, 13), nationality_code: "fra" },
  { first_name: "Sergueï", last_name: "Prokofiev", birth_date: Date.new(1891, 04, 11), death_date: Date.new(1953, 3, 5), nationality_code: "rus" },
]

composers.each do |composer_data|
  Composer.create!(
    first_name: composer_data[:first_name],
    last_name: composer_data[:last_name],
    birth_date: composer_data[:birth_date],
    death_date: composer_data[:death_date],
    short_bio: Faker::Lorem.sentence(word_count: 15),
    bio: Faker::Lorem.paragraph(sentence_count: 8, supplemental: true, random_sentences_to_add: 3),
    nationality: Nationality.find_by(code: composer_data[:nationality_code].upcase)
  )
  composer_count += 1
  puts "-- Created composer: #{Composer.last.first_name} #{Composer.last.last_name}"
end

puts "✅ Created #{Composer.count} composers in total"
