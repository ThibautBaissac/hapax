FactoryBot.define do
  factory :user do
    firstname { Faker::Name.first_name }
    lastname { Faker::Name.last_name }
    email { Faker::Internet.unique.email }
    password { "password123" }
    password_confirmation { "password123" }
    confirmed_at { 1.day.ago }

    # Optional contact information
    phone { Faker::PhoneNumber.phone_number }
    address { Faker::Address.street_address }
    city { Faker::Address.city }
    zip_code { Faker::Address.zip_code }
    bio { Faker::Lorem.paragraph(sentence_count: 3) }

    trait :unconfirmed do
      confirmed_at { nil }
    end

    trait :with_tracking_info do
      current_sign_in_at { 1.hour.ago }
      last_sign_in_at { 1.day.ago }
      current_sign_in_ip { Faker::Internet.ip_v4_address }
      last_sign_in_ip { Faker::Internet.ip_v4_address }
      sign_in_count { 5 }
    end
  end
end
