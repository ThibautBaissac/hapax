FactoryBot.define do
  factory :movement_quote do
    quote { nil }
    movement { nil }
    category { "MyString" }
    location_in_score { "MyString" }
    excerpt_text { "MyString" }
    notes { "MyText" }
  end
end
