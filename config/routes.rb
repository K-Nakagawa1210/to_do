Rails.application.routes.draw do
  # アプリを開いた時に一番最初に表示するページ
  root "tasks#index"

  # 「できた！」ボタンを押した時の設定
  resources :tasks, only: [] do
    member do
      post :complete
    end
    collection do
      get :history
    end
  end

  # (オプション) もし過去の記録を見たい場合はここを後で使います
  # get "history", to: "tasks#history"
end