class AddCoachIdIntoBookings < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings, :coach_id, :string
    add_column :bookings, :request_status, :string
  end
end
