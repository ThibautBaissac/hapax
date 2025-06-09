FactoryBot.define do
  factory :composer do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    birth_date { Faker::Date.between(from: 200.years.ago, to: 50.years.ago) }
    death_date { birth_date.present? ? Faker::Date.between(from: birth_date + 20.years, to: 10.years.ago) : nil }
    short_bio { Faker::Lorem.paragraph(sentence_count: 2) }
    bio { Faker::Lorem.paragraph(sentence_count: 5) }

    association :nationality

    trait :living do
      death_date { nil }
      birth_date { Faker::Date.between(from: 80.years.ago, to: 30.years.ago) }
    end

    trait :baroque do
      birth_date { Faker::Date.between(from: Date.new(1600), to: Date.new(1700)) }
      death_date { Faker::Date.between(from: birth_date + 30.years, to: Date.new(1750)) }
    end

    trait :classical do
      birth_date { Faker::Date.between(from: Date.new(1730), to: Date.new(1800)) }
      death_date { Faker::Date.between(from: birth_date + 25.years, to: Date.new(1850)) }
    end

    trait :romantic do
      birth_date { Faker::Date.between(from: Date.new(1800), to: Date.new(1880)) }
      death_date { Faker::Date.between(from: birth_date + 20.years, to: Date.new(1920)) }
    end

    # Famous composer examples
    trait :bach do
      first_name { "Johann Sebastian" }
      last_name { "Bach" }
      birth_date { Date.new(1685, 3, 31) }
      death_date { Date.new(1750, 7, 28) }
      association :nationality, :german
    end

    trait :mozart do
      first_name { "Wolfgang Amadeus" }
      last_name { "Mozart" }
      birth_date { Date.new(1756, 1, 27) }
      death_date { Date.new(1791, 12, 5) }
      association :nationality, :austrian
    end

    trait :chopin do
      first_name { "Frédéric" }
      last_name { "Chopin" }
      birth_date { Date.new(1810, 3, 1) }
      death_date { Date.new(1849, 10, 17) }
      association :nationality, :polish
    end
  end
end
