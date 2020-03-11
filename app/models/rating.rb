class Rating < ApplicationRecord
  validates :rate, presence: true
  belongs_to :booking
end
