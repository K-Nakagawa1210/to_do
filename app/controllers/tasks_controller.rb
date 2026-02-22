require 'csv'

class TasksController < ApplicationController
  def index
    jst_now = Time.current.in_time_zone('Tokyo')
    @user_score = UserScore.find_or_create_by(id: 1)

    # モード選択
    if params[:reset_mode] == "true"
      session[:mode] = nil
      # URLからパラメータを消してスッキリさせるためにリダイレクト
      return redirect_to root_path 
    end

    if params[:mode].present?
      session[:mode] = params[:mode]
    end
    @mode = session[:mode]

    if @mode.present?
      completed_task_ids = TaskLog.where(completed_at: jst_now.all_day).pluck(:task_id)
      @current_task = Task.where(category: @mode).where.not(id: completed_task_ids).order(:sequence).first

      # クイズ用の設定
      random_gen = Random.new(jst_now.to_date.to_time.to_i)
      
      # 朝と夜でクイズの時間を変える
      if @mode == "morning"
        @start_time_display = "6:#{[0, 10, 20, 30].sample(random: random_gen).to_s.rjust(2, '0')}"
        @end_time_display = "7:#{[0, 5, 10, 15].sample(random: random_gen).to_s.rjust(2, '0')}"
      else
        @start_time_display = "18:#{[0, 15, 30, 45].sample(random: random_gen).to_s.rjust(2, '0')}"
        @end_time_display = "19:#{[0, 15, 30, 45].sample(random: random_gen).to_s.rjust(2, '0')}"
      end
      
      start_h, start_m = @start_time_display.split(':').map(&:to_i)
      end_h, end_m = @end_time_display.split(':').map(&:to_i)
      @correct_total_minutes = (end_h * 60 + end_m) - (start_h * 60 + start_m)

      # 目標時間と残り時間
      limit_h, limit_m = (@mode == "morning" ? [7, 20] : [20, 0])
      @limit_display = "#{limit_h}:#{limit_m.to_s.rjust(2, '0')}"
      limit_time = jst_now.change(hour: limit_h, min: limit_m, sec: 0)
      @minutes_left = ((limit_time - jst_now) / 60).to_i

      # 完了判定
      main_tasks = Task.where(category: @mode).where("sequence > ?", 0)
      completed_count = TaskLog.joins(:task).where(completed_at: jst_now.all_day, tasks: { category: @mode }).where("tasks.sequence > ?", 0).count
      @all_done = (@current_task.nil? && completed_count >= main_tasks.count)
    end

    @show_result = params[:result] == 'success'
    @earned_points = params[:earned_points].to_i
  end

  def complete
    @task = Task.find(params[:id])
    TaskLog.create!(task: @task, completed_at: Time.current)
    redirect_to root_path
  end

  def add_points
    @user_score = UserScore.find(1)
    pts = params[:points].to_i
    @user_score.update(score: @user_score.score + pts)
    redirect_to root_path(result: 'success', earned_points: pts)
  end

  def update_score
    @user_score = UserScore.find_or_create_by(id: 1)
    # パラメータ名を確実に取得して更新
    if @user_score.update(score: params[:score] || params[:user_score][:score])
      flash[:notice] = "ポイントを更新しました"
    end
    # 現在のモードを維持したまま戻る
    redirect_to root_path
  end

  def history
    @tasks_morning = Task.where(category: 'morning').order(:sequence)
    @tasks_evening = Task.where(category: 'evening').order(:sequence)
    
    jst_today = Time.current.in_time_zone('Tokyo').to_date
    start_date = jst_today.beginning_of_month
    end_date = jst_today
    @dates = (start_date..end_date).to_a.reverse

    logs = TaskLog.where(completed_at: start_date.beginning_of_day..end_date.end_of_day)
    @logs_map = logs.each_with_object({}) do |log, hash|
      jst_time = log.completed_at.in_time_zone('Tokyo')
      hash[[jst_time.to_date, log.task_id]] = { time: jst_time.strftime("%H:%M"), id: log.id }
    end

    respond_to do |format|
      format.html
      format.csv do
        # Excel文字化け防止のBOMを追加
        csv_data = "\xEF\xBB\xBF" + generate_csv(@dates, @tasks_morning, @tasks_evening, @logs_map)
        
        send_data csv_data, 
                  filename: "ryuma_record_#{jst_today.strftime('%Y%m')}.csv",
                  type: 'text/csv; charset=utf-8'
      end
    end
  end

  private

  def generate_csv(dates, morning_tasks, evening_tasks, logs_map)
    CSV.generate(headers: true) do |csv|
      header = ["日付"] + morning_tasks.pluck(:name) + evening_tasks.pluck(:name)
      csv << header
      dates.each do |date|
        row = [date.strftime("%Y/%m/%d")]
        (morning_tasks + evening_tasks).each do |task|
          row << (logs_map[[date, task.id]] ? logs_map[[date, task.id]][:time] : "-")
        end
        csv << row
      end
    end
  end
end