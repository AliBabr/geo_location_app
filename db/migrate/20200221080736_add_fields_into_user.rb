class AddFieldsIntoUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :name, :string
    add_column :users, :city, :string
    add_column :users, :phone, :string
    add_column :users, :category, :string
    add_column :users, :coach_type, :string
    add_column :users, :about, :string
    add_column :users, :background, :string
    add_column :users, :role, :integer
  end
end
