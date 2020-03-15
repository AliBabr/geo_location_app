class Booking < ApplicationRecord
  validates :price, presence: true
  belongs_to :user
  belongs_to :lesson
  has_one :rating
  has_one :calling
end
