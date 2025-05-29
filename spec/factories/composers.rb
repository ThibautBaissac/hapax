FactoryBot.define do
  factory :composer do
    first_name { "MyString" }
    last_name { "MyString" }
    birth_date { "2025-05-29" }
    death_date { "2025-05-29" }
    short_bio { "MyText" }
    bio { "MyText" }
    nationnality { "MyString" }
  end
end
