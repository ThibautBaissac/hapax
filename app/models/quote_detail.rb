class QuoteDetail < ApplicationRecord
  belongs_to :quote
  belongs_to :detailable, polymorphic: true
end
