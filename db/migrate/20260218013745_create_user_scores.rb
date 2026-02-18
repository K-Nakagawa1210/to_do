class CreateUserScores < ActiveRecord::Migration[7.1]
  def change
    create_table :user_scores do |t|
      t.integer :score

      t.timestamps
    end
  end
end
