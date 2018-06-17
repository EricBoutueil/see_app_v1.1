Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  devise_for :users, controllers: { registrations: "registrations" }

  scope '(:locale)', locale: /en|es/ do

    root to: 'harbours#index'
    get '/geojson', to: 'harbours#geojson', format: :js
    get "/conditions_generales_d_utilisation", to: "pages#cgu", as: :cgu
    resources :harbours, only:[:index]
    get '/import', to: "movements#import", as: :new_import
    post '/import', to: "movements#import", as: :import
    post '/import-light', to: "movements#import_light", as: :import_light
    resources :types, only:[:index]
  end
end
