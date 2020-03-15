class Calling < ApplicationRecord
  validates :coach_id, presence: true
  validates :student_id, presence: true
  validates :duration, presence: true
  validates :time_of_call, presence: true

  belongs_to :booking
end
