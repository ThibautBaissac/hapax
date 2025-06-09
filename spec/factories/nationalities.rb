FactoryBot.define do
  factory :nationality do
    sequence(:name) { |n| "#{Faker::Nation.nationality} #{n}" }
    sequence(:code) { |n| "C#{n.to_s.rjust(2, '0')}" }

    trait :french do
      name { "French" }
      code { "FR" }
    end

    trait :german do
      name { "German" }
      code { "DE" }
    end

    trait :italian do
      name { "Italian" }
      code { "IT" }
    end

    trait :austrian do
      name { "Austrian" }
      code { "AT" }
    end

    trait :polish do
      name { "Polish" }
      code { "PL" }
    end
  end
end
