require 'faker'

puts "🎼 Creating composers"

composer_count = 0
total_composer_count = 15

# Some famous classical composers for more realistic data
famous_composers = [
  { first_name: "Wolfgang Amadeus", last_name: "Mozart", birth_date: Date.new(1756, 1, 27), death_date: Date.new(1791, 12, 5), nationality: "Austrian" },
  { first_name: "Ludwig van", last_name: "Beethoven", birth_date: Date.new(1770, 12, 17), death_date: Date.new(1827, 3, 26), nationality: "German" },
  { first_name: "Johann Sebastian", last_name: "Bach", birth_date: Date.new(1685, 3, 31), death_date: Date.new(1750, 7, 28), nationality: "German" },
  { first_name: "Frédéric", last_name: "Chopin", birth_date: Date.new(1810, 3, 1), death_date: Date.new(1849, 10, 17), nationality: "Polish" },
  { first_name: "Franz", last_name: "Schubert", birth_date: Date.new(1797, 1, 31), death_date: Date.new(1828, 11, 19), nationality: "Austrian" }
]

# Create famous composers first
famous_composers.each do |composer_data|
  Composer.create!(
    first_name: composer_data[:first_name],
    last_name: composer_data[:last_name],
    birth_date: composer_data[:birth_date],
    death_date: composer_data[:death_date],
    nationnality: composer_data[:nationality],
    short_bio: Faker::Lorem.sentence(word_count: 15),
    bio: Faker::Lorem.paragraph(sentence_count: 8, supplemental: true, random_sentences_to_add: 3)
  )
  composer_count += 1
  puts "-- Created composer #{composer_count}/#{total_composer_count}: #{Composer.last.first_name} #{Composer.last.last_name}"
end

# Create additional fictional composers
(total_composer_count - famous_composers.length).times do
  birth_year = rand(1600..1950)
  death_year = birth_year + rand(30..90)

  Composer.create!(
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    birth_date: Date.new(birth_year, rand(1..12), rand(1..28)),
    death_date: Date.new(death_year, rand(1..12), rand(1..28)),
    nationnality: Faker::Nation.nationality,
    short_bio: Faker::Lorem.sentence(word_count: 15),
    bio: Faker::Lorem.paragraph(sentence_count: 8, supplemental: true, random_sentences_to_add: 3)
  )
  composer_count += 1
  puts "-- Created composer #{composer_count}/#{total_composer_count}: #{Composer.last.first_name} #{Composer.last.last_name}"
end

puts "✅ Created #{Composer.count} composers in total"
