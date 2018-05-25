Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  devise_for :users, controllers: { registrations: "registrations" }

  scope '(:locale)', locale: /en|es/ do

    root to: 'harbours#index'
    resources :harbours, only:[:index]
    get '/import', to: "movements#import", as: :new_import
    post '/import', to: "movements#import", as: :import
    resources :types, only:[:index]
  end
end
