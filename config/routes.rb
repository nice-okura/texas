# coding: utf-8
Texas::Application.routes.draw do
  get "users/new"

  get "users/show"

  get '/index', :to => 'public#index'
  root :to => 'logins#new'
  
  # ログイン
  get '/logins', :to => 'logins#new'
  post '/logins', :to => 'logins#create'
  
  # ロビー
  get '/lobby', :to => 'logins#lobby'
end
