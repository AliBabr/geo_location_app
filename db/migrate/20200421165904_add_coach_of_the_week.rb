class AddCoachOfTheWeek < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :is_coach_of_the_week, :boolean, :default => false
  end
end
