class TaskLogsController < ApplicationController
  def edit
    @task_log = TaskLog.find(params[:id])
  end

  def update
    @task_log = TaskLog.find(params[:id])
    if @task_log.update(task_log_params)
      redirect_to history_tasks_path, notice: "記録を 直しました"
    else
      render :edit
    end
  end

  def delete_log
    @task_log = TaskLog.find(params[:id])
    @task_log.destroy
    redirect_to history_tasks_path, notice: "記録を 消しました"
  end

  def destroy
    @task_log = TaskLog.find(params[:id])
    @task_log.destroy
    redirect_to history_tasks_path, notice: "記録を 消しました"
  end

  private

  def task_log_params
    params.require(:task_log).permit(:completed_at)
  end
end