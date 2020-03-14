class CreateMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :messages do |t|
      t.text :text
      t.integer :status, default: 2
      t.timestamps
    end
  end
end
