require './lib/activejob-google_cloud_tasks/router'

Rails.application.routes.draw do
  root 'welcome#index'

  get '/welcome', to: 'welcome#index'

  mount Activejob::GoogleCloudTasks::Router, at: '/activejobs'
end
