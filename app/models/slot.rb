class Slot < ApplicationRecord
  enum day: {
    "Monday" => 0,
    "Tuesday" => 1,
    "Wednesday" => 2,
    "Thursday" => 3,
    "Friday" => 4,
    "Saturday" => 5,
    "Sunday" => 6
  }

  belongs_to :user, optional: true

end
