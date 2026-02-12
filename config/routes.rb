Rails.application.routes.draw do
  root "tasks#index"

  resources :tasks, only: [] do
    member do
      post :complete
    end
    collection do
      get :history
    end
  end

  resources :task_logs, only: [:edit, :update] do
    member do
      get :delete_log  # GETで削除アクションへ行くルートを追加
    end
  end
end