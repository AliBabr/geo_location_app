class BookingsRealtions < ActiveRecord::Migration[5.2]
  def change
    add_reference(:bookings, :lesson, index: false)
    add_reference(:bookings, :user, index: false)
    change_column :bookings, :user_id, :string
  end
end
