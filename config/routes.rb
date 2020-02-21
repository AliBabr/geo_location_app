Rails.application.routes.draw do
  # devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      resources :users do
        collection do
          get :sign_in
          post :sign_up
          put :log_out
          put :update_password
          put :update_account
          put :forgot_password
          post :reset_password
          get :get_user
        end
        member do
          get :reset
        end
      end
      post "/notifications/toggle_notification", to: "notifications#toggle_notification"
      # resources :places, only: :index
      # resources :history, only: [:create, :index]
    end
  end

  root to: "home#index"
end
