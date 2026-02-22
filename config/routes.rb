Rails.application.routes.draw do
  root "tasks#index"

  resources :tasks, only: [] do
    member do
      post :complete
    end
    collection do
      get :history
      patch :update_score
      post :add_points
    end
  end

  resources :task_logs, only: [:edit, :update] do
    member do
      get :delete_log
    end
    collection do
      delete :delete_by_date
    end
  end
end