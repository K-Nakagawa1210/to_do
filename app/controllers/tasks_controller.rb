class TasksController < ApplicationController
  def index
    # 日本時間の「今日」を基準にする
    jst_now = Time.current.in_time_zone('Tokyo')
    
    # 1. 今日の完了済みタスクIDを取得
    completed_task_ids = TaskLog.where(completed_at: jst_now.all_day).pluck(:task_id)
    
    # 2. まだ終わっていない最初のタスクを取得
    @current_task = Task.where.not(id: completed_task_ids).order(:sequence).first

    # 3. クイズ用の時間計算
    departure_time = jst_now.change(hour: 7, min: 20, sec: 0)
    @minutes_left = ((departure_time - jst_now) / 60).to_i

    # 4. 全タスク完了判定（おはよう=0 を除く 1〜8 が終わっているか）
    main_tasks = Task.where("sequence > ?", 0)
    main_tasks_count = main_tasks.count
    
    completed_main_tasks_count = TaskLog.joins(:task)
                                        .where(completed_at: jst_now.all_day)
                                        .where("tasks.sequence > ?", 0).count

    # 「次のタスクがない」かつ「メインタスクが全て完了している」ならおめでとう画面
    if @current_task.nil? && completed_main_tasks_count >= main_tasks_count
      @all_done = true
    else
      @all_done = false
    end
  end

  def complete
    @task = Task.find(params[:id])
    # 確実に日本時間でログを作成
    TaskLog.create!(task: @task, completed_at: Time.current.in_time_zone('Tokyo'))

    # status: :see_other は Rails 7 / Turbo の本番環境で必須に近い設定です
    redirect_to root_path, status: :see_other
  end

  def history
    @tasks = Task.order(:sequence)
    
    # 日本時間での今月1日〜今日
    jst_today = Time.current.in_time_zone('Tokyo').to_date
    start_date = jst_today.beginning_of_month
    end_date = jst_today
    
    @logs_map = TaskLog.where(completed_at: start_date.beginning_of_day..end_date.end_of_day)
                       .order(:completed_at)
                       .each_with_object({}) do |log, hash|
                         # 日本時間に変換してから日付と時刻を取得
                         jst_time = log.completed_at.in_time_zone('Tokyo')
                         date = jst_time.to_date
                         hash[[date, log.task_id]] = jst_time.strftime("%H:%M")
                       end
    
    @dates = (start_date..end_date).to_a.reverse
  end
end