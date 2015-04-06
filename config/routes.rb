Rails.application.routes.draw do

  root 'questions#index'

  post '/search' => 'application#search'


  get '/login' => 'sessions#new'
  post '/login' => 'sessions#create'
  delete '/logout' => 'sessions#destroy'

  resources :categories, except: :destroy do
    member do
      post 'sub'
      post 'unsub'
    end

    resources :questions, only: [:create, :show, :index], shallow: true do
      post 'vote', on: :member

      resources :comments, only: [:create] do
        member do
          post 'vote'
          post 'best_answer'
        end
      end
    end
  end

  get '/register' => 'users#new'
  resources :users, except: [:destroy] do

    member do
      resources :messages, only: [:new, :create]
      get 'avatar'
      patch 'update_avatar'
      delete 'delete_avatar'
    end
  end

  resources :email_verifications, only: :edit

  resources :password_resets, only: [:new, :create, :edit, :update]
end
