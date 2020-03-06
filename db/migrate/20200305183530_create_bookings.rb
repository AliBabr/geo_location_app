class CreateBookings < ActiveRecord::Migration[5.2]
  def change
    create_table :bookings do |t|
      t.string :payment_status
      t.float :price
      t.datetime :time
      t.string :booking_status
      t.timestamps
    end
  end
end
