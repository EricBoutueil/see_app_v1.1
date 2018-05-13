Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  devise_for :users, controllers: { registrations: "registrations" }

  scope '(:locale)', locale: /en|es/ do

    root to: 'harbours#index'
    resources :harbours, only:[:index]
    resources :movements, only:[:index] do
      collection do
        post 'import'
      end
    end
    resources :types, only:[:index]

  end
end
