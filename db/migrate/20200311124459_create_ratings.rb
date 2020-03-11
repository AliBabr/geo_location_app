class CreateRatings < ActiveRecord::Migration[5.2]
  def change
    create_table :ratings do |t|
      t.float :rate
      t.string :review
      t.string :student_id
      t.string :coach_id
      t.timestamps
    end
  end
end
