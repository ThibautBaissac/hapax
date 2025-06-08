FactoryBot.define do
  factory :quote_detail do
    association :detailable, factory: :work
    category { "inspiration" }
    location { "Page 42" }
    excerpt_text { "This is a sample excerpt from the work" }
    notes { "Additional notes about this quote detail" }
  end
end
