class AddTotalStepsIntoCategory < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :total_steps, :integer, default: 0
  end
end
