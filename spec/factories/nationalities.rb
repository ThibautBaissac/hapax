FactoryBot.define do
  factory :nationality do
    name { Faker::Nation.nationality }
    code { Faker::Address.country_code }

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
