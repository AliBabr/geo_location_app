class CreateFavorites < ActiveRecord::Migration[5.2]
  def change
    create_table :favorites do |t|
      t.string :student_id
      t.string :coach_id
      t.timestamps
    end
  end
end
