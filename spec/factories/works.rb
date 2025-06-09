FactoryBot.define do
  factory :work do
    title { Faker::Music.album }
    opus { "Op. #{Faker::Number.between(from: 1, to: 200)}" }
    description { Faker::Lorem.paragraph(sentence_count: 3) }
    duration { Faker::Number.between(from: 180, to: 7200) } # 3 minutes to 2 hours in seconds
    form { Work.forms.keys.sample }
    structure { Work.structures.keys.sample }
    instrumentation { Faker::Music.instrument }
    recorded { [true, false].sample }
    start_date_composed { Faker::Date.between(from: 50.years.ago, to: 1.year.ago) }
    end_date_composed { start_date_composed.present? ? Faker::Date.between(from: start_date_composed, to: Date.current) : nil }
    unsure_start_date { [true, false].sample }
    unsure_end_date { [true, false].sample }

    association :composer

    trait :symphony do
      form { :symphony }
      structure { :movement }
      title { "Symphony No. #{Faker::Number.between(from: 1, to: 10)}" }
      duration { Faker::Number.between(from: 1800, to: 3600) } # 30-60 minutes
    end

    trait :sonata do
      form { :sonata }
      structure { :movement }
      title { "Sonata in #{['C', 'D', 'E', 'F', 'G', 'A', 'B'].sample} #{['major', 'minor'].sample}" }
      duration { Faker::Number.between(from: 900, to: 2400) } # 15-40 minutes
    end

    trait :concerto do
      form { :concerto }
      structure { :movement }
      title { "#{Faker::Music.instrument.capitalize} Concerto" }
      duration { Faker::Number.between(from: 1200, to: 2700) } # 20-45 minutes
    end

    trait :opera do
      form { :opera }
      structure { :act }
      title { Faker::Book.title }
      duration { Faker::Number.between(from: 5400, to: 14400) } # 1.5-4 hours
    end

    trait :short_piece do
      form { [:prelude, :etude, :nocturne].sample }
      structure { :melody }
      duration { Faker::Number.between(from: 60, to: 600) } # 1-10 minutes
    end

    trait :with_movements do
      after(:create) do |work|
        create_list(:movement, 3, work: work)
      end
    end

    trait :with_quotes do
      after(:create) do |work|
        quote = create(:quote)
        create(:quote_detail, quote: quote, detailable: work)
      end
    end
  end
end
