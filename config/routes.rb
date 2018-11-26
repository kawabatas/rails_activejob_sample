Rails.application.routes.draw do
  root 'welcome#index'
  get '/welcome', to: 'welcome#index'

  get '/job', to: 'welcome#sample_job'

  mount Activejob::GoogleCloudTasks::Rack, at: Activejob::GoogleCloudTasks::Config.path
end
