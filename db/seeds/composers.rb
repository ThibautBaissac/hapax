require 'faker'

puts "🎼 Creating composers"

composer_count = 0

composers = [
  { first_name: "Olivier", last_name: "Greif", birth_date: Date.new(1950, 1, 3), death_date: Date.new(2000, 5, 13), nationality: "French" },
  { first_name: "Ludwig van", last_name: "Beethoven", birth_date: Date.new(1770, 12, 17), death_date: Date.new(1827, 3, 26), nationality: "German" },
]

composers.each do |composer_data|
  Composer.create!(
    first_name: composer_data[:first_name],
    last_name: composer_data[:last_name],
    birth_date: composer_data[:birth_date],
    death_date: composer_data[:death_date],
    short_bio: Faker::Lorem.sentence(word_count: 15),
    bio: Faker::Lorem.paragraph(sentence_count: 8, supplemental: true, random_sentences_to_add: 3),
    nationality_id: Nationality.pluck(:id).sample
  )
  composer_count += 1
  puts "-- Created composer: #{Composer.last.first_name} #{Composer.last.last_name}"
end

puts "✅ Created #{Composer.count} composers in total"
