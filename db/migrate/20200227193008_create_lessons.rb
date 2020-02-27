class CreateLessons < ActiveRecord::Migration[5.2]
  def change
    create_table :lessons do |t|
      t.string :title
      t.text :description
      t.datetime :availability
      t.float :price
      t.string :duration
      t.timestamps
    end
  end
end
