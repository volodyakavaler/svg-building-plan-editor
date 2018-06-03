Rails.application.routes.draw do
  resources :roomtypes
  resources :rooms do
    collection do
      get :search
    end
  end
  resources :floors
  resources :buildings
  resources :points
  resources :polygons
  resources :campuses
  devise_for :users, path: '', path_names: { sign_in: 'login', sign_out: 'logout' },
  controllers: { registrations: 'registrations' }

  root :to => 'welcome#index'

  resources :users
end
