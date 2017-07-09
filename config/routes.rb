Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  devise_for :users, skip: :all

  root to: 'application#home'

  scope :api, defaults: {format: :json} do
    devise_scope :user do
      # TODO destroy user
      resources :users, only: [:create, :show, :update]
      # resources :passwords, only: [:create, :update]
    end
  end
end
