require 'faker'

puts "🌱 Creating users"

user_count = 0
total_user_count = 10

total_user_count.times do
  User.create!(
    email: Faker::Internet.unique.email,
    password: 'password123',
    firstname: Faker::Name.first_name,
    lastname: Faker::Name.last_name,
    phone: Faker::PhoneNumber.phone_number,
    address: Faker::Address.street_address,
    city: Faker::Address.city,
    zip_code: Faker::Address.zip_code,
    bio: Faker::Lorem.paragraph(sentence_count: 10, supplemental: true, random_sentences_to_add: 4),
    confirmed_at: Time.current
  )
  user_count += 1
  puts "-- Created user #{user_count}/#{total_user_count}: #{User.last.email}"
end
puts "✅ Created #{User.count} users in total"
