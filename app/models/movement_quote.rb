class MovementQuote < ApplicationRecord
  belongs_to :quote
  belongs_to :movement
end
