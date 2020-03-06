class AddTimesIntoBookings < ActiveRecord::Migration[5.2]
  def change
    rename_column :bookings, :time, :start_time
    add_column :bookings, :end_time, :datetime
  end
end
