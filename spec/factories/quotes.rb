FactoryBot.define do
  factory :quote do
    title { Faker::Book.title }
    author { Faker::Book.author }
    notes { Faker::Lorem.paragraph(sentence_count: 2) }

    trait :classical_music_quote do
      title { "On Musical Expression" }
      author { "Leonard Bernstein" }
    end

    trait :philosophy_quote do
      title { "The Meaning of Music" }
      author { "Arthur Schopenhauer" }
    end

    trait :composer_quote do
      author { Faker::Name.name }
      title { "Reflections on Composition" }
    end

    trait :with_details_for_work do
      after(:create) do |quote|
        work = create(:work)
        create(:quote_detail, quote: quote, detailable: work)
      end
    end

    trait :with_details_for_movement do
      after(:create) do |quote|
        movement = create(:movement)
        create(:quote_detail, quote: quote, detailable: movement)
      end
    end

    trait :with_images do
      after(:create) do |quote|
        # Note: In a real test environment, you might want to attach actual test images
        # This would require additional setup with test image files
      end
    end
  end
end
