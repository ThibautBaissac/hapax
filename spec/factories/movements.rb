FactoryBot.define do
  factory :movement do
    title { ["Allegro", "Andante", "Adagio", "Presto", "Largo", "Vivace"].sample }
    position { Faker::Number.between(from: 1, to: 4) }
    duration { Faker::Number.between(from: 180, to: 1800) } # 3-30 minutes in seconds
    description { Faker::Lorem.paragraph(sentence_count: 2) }

    association :work

    trait :first_movement do
      title { "I. Allegro" }
      position { 1 }
      duration { Faker::Number.between(from: 600, to: 1200) } # 10-20 minutes
    end

    trait :second_movement do
      title { "II. Andante" }
      position { 2 }
      duration { Faker::Number.between(from: 300, to: 900) } # 5-15 minutes
    end

    trait :third_movement do
      title { "III. Menuetto" }
      position { 3 }
      duration { Faker::Number.between(from: 240, to: 480) } # 4-8 minutes
    end

    trait :final_movement do
      title { "IV. Presto" }
      position { 4 }
      duration { Faker::Number.between(from: 360, to: 720) } # 6-12 minutes
    end

    trait :with_quotes do
      after(:create) do |movement|
        quote = create(:quote)
        create(:quote_detail, quote: quote, detailable: movement)
      end
    end
  end
end
