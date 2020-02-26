class CreateLeasonTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :leason_types do |t|
      t.string :name
      t.text :description
      t.string :color
      t.timestamps
    end
  end
end
