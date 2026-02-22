# app/controllers/tasks_controller.rb
def index
  jst_now = Time.current.in_time_zone('Tokyo')
  @user_score = UserScore.find_or_create_by(id: 1)

  # モード選択（URLパラメータがあればセッションに保存、なければセッションから読み込み）
  session[:mode] = params[:mode] if params[:mode].present?
  @mode = session[:mode] # "morning" か "evening"

  if @mode.present?
    # そのモードのタスクのみ取得
    completed_task_ids = TaskLog.where(completed_at: jst_now.all_day).pluck(:task_id)
    @current_task = Task.where(category: @mode).where.not(id: completed_task_ids).order(:sequence).first

    # クイズ用の設定
    random_gen = Random.new(jst_now.to_date.to_time.to_i)
    @start_time_display = "18:#{[0, 15, 30, 45].sample(random: random_gen).to_s.rjust(2, '0')}"
    @end_time_display = "19:#{[0, 15, 30, 45].sample(random: random_gen).to_s.rjust(2, '0')}"
    
    start_h, start_m = @start_time_display.split(':').map(&:to_i)
    end_h, end_m = @end_time_display.split(':').map(&:to_i)
    @correct_total_minutes = (end_h * 60 + end_m) - (start_h * 60 + start_m)

    # 目標時間と残り時間（朝は7:20、夜は20:00）
    limit_h, limit_m = (@mode == "morning" ? [7, 20] : [20, 0])
    @limit_display = "#{limit_h}:#{limit_m.to_s.rjust(2, '0')}"
    departure_limit = jst_now.change(hour: limit_h, min: limit_m, sec: 0)
    @minutes_left = ((departure_limit - jst_now) / 60).to_i

    # 完了判定
    main_tasks = Task.where(category: @mode).where("sequence > ?", 0)
    completed_count = TaskLog.joins(:task).where(completed_at: jst_now.all_day, tasks: { category: @mode }).where("tasks.sequence > ?", 0).count
    @all_done = (@current_task.nil? && completed_count >= main_tasks.count)
  end

  @show_result = params[:result] == 'success'
  @earned_points = params[:earned_points].to_i
end

def history
  @tasks_morning = Task.where(category: 'morning').order(:sequence)
  @tasks_evening = Task.where(category: 'evening').order(:sequence)
  
  jst_today = Time.current.in_time_zone('Tokyo').to_date
  start_date = jst_today.beginning_of_month
  end_date = jst_today
  @dates = (start_date..end_date).to_a.reverse

  # 記録の取得
  logs = TaskLog.where(completed_at: start_date.beginning_of_day..end_date.end_of_day)
  @logs_map = logs.each_with_object({}) do |log, hash|
    jst_time = log.completed_at.in_time_zone('Tokyo')
    hash[[jst_time.to_date, log.task_id]] = { 
      time: jst_time.strftime("%H:%M"), 
      id: log.id 
    }
  end

  # CSV出力機能
  respond_to do |format|
    format.html
    format.csv do
      send_data generate_csv(@dates, @tasks_morning, @tasks_evening, @logs_map), 
                filename: "竜馬くんの記録_#{jst_today.strftime('%Y%m')}.csv"
    end
  end
end

private

def generate_csv(dates, morning_tasks, evening_tasks, logs_map)
  CSV.generate(headers: true) do |csv|
    # ヘッダー行
    header = ["日付"] + morning_tasks.pluck(:name) + evening_tasks.pluck(:name)
    csv << header

    # データ行
    dates.each do |date|
      row = [date.strftime("%Y/%m/%d")]
      (morning_tasks + evening_tasks).each do |task|
        row << (logs_map[[date, task.id]] ? logs_map[[date, task.id]][:time] : "-")
      end
      csv << row
    end
  end
end