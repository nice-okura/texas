# coding: utf-8
Texas::Application.routes.draw do
  get '/index', :to => 'public#index'
  root :to => 'logins#new'
  
  # ログイン
  get '/logins', :to => 'logins#new'
  post '/logins', :to => 'logins#create'
  
  # ログアウト
  delete '/logout', :to => 'logins#destroy'

  # ロビー
  get '/lobby', :to => 'logins#lobby'
end
