class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :lesson
  has_one :rating
end
