class CreateTaskLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :task_logs do |t|
      t.references :task, null: false, foreign_key: true
      t.datetime :completed_at

      t.timestamps
    end
  end
end
