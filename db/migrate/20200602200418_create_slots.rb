class CreateSlots < ActiveRecord::Migration[5.2]
  def change
    create_table :slots do |t|
      t.integer :day
      t.datetime :start_time
      t.datetime :end_time
      t.timestamps
    end
  end
end
