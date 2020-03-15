class CreateCallings < ActiveRecord::Migration[5.2]
  def change
    create_table :callings do |t|
      t.string :student_id
      t.string :coach_id
      t.string :duration
      t.string :time_of_call

      t.timestamps
    end
  end
end
