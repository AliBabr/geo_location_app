class Category < ApplicationRecord
  has_one_attached :image
  has_many :users
  has_many :lessons

  private

  def self.search(pattern)
    if pattern.blank? # blank? covers both nil and empty string
      all
    else
      where("name LIKE ?", "%#{pattern}%")
    end
  end
end
