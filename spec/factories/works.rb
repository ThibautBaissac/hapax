FactoryBot.define do
  factory :work do
    opus { "MyString" }
    title { "MyString" }
    description { "MyText" }
    duration { 1 }
    composer { nil }
  end
end
