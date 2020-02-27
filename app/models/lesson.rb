class Lesson < ApplicationRecord
  belongs_to :leason_type
  belongs_to :category
  belongs_to :user
end
