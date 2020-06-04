class AddNumberOfStudentsIntoLesson < ActiveRecord::Migration[5.2]
  def change
    add_column :lessons, :spots, :integer, default: 5
  end
end
