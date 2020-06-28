class AddChargeIntoBooking < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings, :charge_id, :string
  end
end
