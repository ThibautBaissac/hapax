FactoryBot.define do
  factory :quote_detail do
    association :quote
    association :detailable, factory: :work

    category { ["inspiration", "analysis", "historical", "personal", "technical"].sample }
    location { "Page #{Faker::Number.between(from: 1, to: 500)}" }
    excerpt_text { Faker::Lorem.paragraph(sentence_count: 3) }
    notes { Faker::Lorem.paragraph(sentence_count: 2) }

    trait :for_work do
      association :detailable, factory: :work
      location { "Chapter #{Faker::Number.between(from: 1, to: 20)}" }
    end

    trait :for_movement do
      association :detailable, factory: :movement
      location { "Bar #{Faker::Number.between(from: 1, to: 200)}" }
    end

    trait :inspiration do
      category { "inspiration" }
      excerpt_text { "This passage inspired the composer's creative process..." }
    end

    trait :analysis do
      category { "analysis" }
      excerpt_text { "The harmonic structure reveals..." }
    end

    trait :historical do
      category { "historical" }
      excerpt_text { "During this period, the composer..." }
    end

    trait :technical do
      category { "technical" }
      excerpt_text { "The performance technique requires..." }
    end
  end
end
