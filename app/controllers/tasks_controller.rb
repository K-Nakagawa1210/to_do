class TasksController < ApplicationController
  def index
    jst_now = Time.current.in_time_zone('Tokyo')
    completed_task_ids = TaskLog.where(completed_at: jst_now.all_day).pluck(:task_id)
    @current_task = Task.where.not(id: completed_task_ids).order(:sequence).first

    # --- クイズの生成（ランダムな時間の計算） ---
    # その日の日付をシードにして、リロードしてもその日は同じ問題が出るようにする
    random_gen = Random.new(jst_now.to_date.to_time.to_i)
    
    # 開始時間を 6:00〜6:30 の間で 5分刻みで生成
    start_h = 6
    start_m = [0, 5, 10, 15, 20, 25, 30].sample(random: random_gen)
    @start_time_display = "#{start_h}:#{start_m.to_s.rjust(2, '0')}"

    # 終了時間を 7:00〜7:30 の間で 5分刻みで生成
    end_h = 7
    end_m = [0, 5, 10, 15, 20, 25, 30].sample(random: random_gen)
    @end_time_display = "#{end_h}:#{end_m.to_s.rjust(2, '0')}"

    # 正解の合計分を計算（例：6:10〜7:20 なら 70分）
    @correct_total_minutes = (end_h * 60 + end_m) - (start_h * 60 + start_m)
    
    # 出発時刻（警告用）はこれまで通り 7:20
    departure_limit = jst_now.change(hour: 7, min: 20, sec: 0)
    @minutes_left = ((departure_limit - jst_now) / 60).to_i
    # ------------------------------------------

    main_tasks_count = Task.where("sequence > ?", 0).count
    completed_main_tasks_count = TaskLog.joins(:task)
                                        .where(completed_at: jst_now.all_day)
                                        .where("tasks.sequence > ?", 0).count
    @all_done = (@current_task.nil? && completed_main_tasks_count >= main_tasks_count)
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