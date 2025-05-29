FactoryBot.define do
  factory :movement_citation do
    citation { nil }
    movement { nil }
    category { "MyString" }
    location_in_score { "MyString" }
    excerpt_text { "MyString" }
    notes { "MyText" }
  end
end
