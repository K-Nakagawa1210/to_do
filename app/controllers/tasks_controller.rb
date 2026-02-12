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
    @tasks = Task.order(:sequence)
    
    # 今月1日の0:00から、今日の23:59までの範囲
    start_date = Date.today.beginning_of_month
    end_date = Date.today
    
    @logs_map = TaskLog.where(completed_at: start_date.beginning_of_day..end_date.end_of_day)
                      .order(:completed_at)
                      .each_with_object({}) do |log, hash|
                        date = log.completed_at.to_date
                        hash[[date, log.task_id]] = log.completed_at.strftime("%H:%M")
                      end
    
    # 今月1日から今日までの日付リストを、新しい順（降順）に並べる
    @dates = (start_date..end_date).to_a.reverse
  end
end