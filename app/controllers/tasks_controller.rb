class TasksController < ApplicationController
  def index
    # 今日の完了済みタスクIDを取得
    completed_task_ids = TaskLog.where(completed_at: Time.zone.now.all_day).pluck(:task_id)
    
    # まだ終わっていない最初のタスクを取得
    @current_task = Task.where.not(id: completed_task_ids).order(:sequence).first

    if @current_task.nil?
      # 全て完了している場合、クイズ用の時間を計算
      departure_time = Time.zone.now.change(hour: 7, min: 20)
      @minutes_left = ((departure_time - Time.zone.now) / 60).to_i
    end
  end

  def complete
    @task = Task.find(params[:id])
    TaskLog.create!(task: @task, completed_at: Time.zone.now)
    redirect_to root_path
  end

  def history
    # 過去7日間の記録を、新しい順に取得する
    @logs = TaskLog.includes(:task).where(completed_at: 7.days.ago..Time.zone.now).order(completed_at: :desc)
  end
end