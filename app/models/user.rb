class User < ApplicationRecord
  acts_as_token_authenticatable User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :profile_photo
  has_many :lessons
  has_many :slots
  belongs_to :leason_type, optional: true
  belongs_to :category, optional: true
  has_many :bookings

  enum role: {
    "Coach" => 1,
    "Student" => 2,
    "Admin" => 3,
  }

  private

  def self.search(pattern)
    if pattern.blank? # blank? covers both nil and empty string
      where(role: "Coach")
    else
      where("name LIKE ?", "%#{pattern}%")
    end
  end

  def after_successful_token_authentication
    # Make the authentication token to be disposable - for example
    renew_authentication_token!
  end

  # Function will return false if token doesn't mtch but return nil if user not found
  def self.validate_token(id, auth_token)
    user = self.find_by_id(id)
    if user.present?
      user.authentication_token == auth_token
    end
  end
end
