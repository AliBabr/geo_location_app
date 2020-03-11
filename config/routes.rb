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
      resources :types do
        collection do
          put :update_type
          delete :destroy_type
        end
      end
      resources :categories do
        collection do
          put :update_category
          delete :destroy_category
        end
      end
      resources :lessons do
        collection do
          put :update_lesson
          delete :destroy_lesson
          get :get_lesson
          put :add_favorite
        end
      end

      resources :news do
        collection do
          put :update_news
          delete :destroy_news
          get :get_news
        end
      end

      resources :payments do
        collection do
          put :process_payment
          put :add_card_token
        end
      end

      resources :sessions do
        collection do
          get :get_student_active_sessions
          get :get_sessions_sorted_by_dates
          get :get_session_by_date
          get :get_session_by_id
        end
      end

      resources :bookings do
        collection do
          put :update_booking
          delete :destroy_booking
          get :get_booking
          get :get_coach_booking_requests
          get :get_student_bookings
          put :accept_or_decline_booking
        end
      end

      resources :ratings

      resources :coaches do
        collection do
          get :get_coach
          get :get_coach_lessons
          put :add_favorite
          get :search_by_name
          get :search_by_category
          get :get_by_category
        end
      end

      post "/notifications/toggle_notification", to: "notifications#toggle_notification"
      # resources :places, only: :index
      # resources :history, only: [:create, :index]
    end
  end

  root to: "home#index"
end
