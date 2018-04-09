Rails.application.routes.draw do
  devise_for :users

  scope '(:locale)', locale: /en|es/ do

    root to: 'harbours#index'
    resources :harbours, only:[:index]
    resources :movements, only:[:index]

  end
end
