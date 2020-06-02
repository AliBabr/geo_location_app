class Slot < ApplicationRecord
  enum day: {
    "Monday" => 1,
    "Tuesday" => 2,
    "Wednesday" => 3,
    "Thursday" => 4,
    "Friday" => 5,
    "Saturday" => 6,
    "Sunday" => 7
  }

  belongs_to :user, optional: true

end
