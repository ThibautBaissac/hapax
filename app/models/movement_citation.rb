class MovementCitation < ApplicationRecord
  belongs_to :citation
  belongs_to :movement
end
