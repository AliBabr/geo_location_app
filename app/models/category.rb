class Category < ApplicationRecord
  has_one_attached :image
  has_many :users
  has_many :lessons
end
