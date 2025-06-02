FactoryBot.define do
  factory :quote_detail do
    quote { nil }
    movement { nil }
    category { "MyString" }
    location { "MyString" }
    excerpt_text { "MyString" }
    notes { "MyText" }
  end
end
