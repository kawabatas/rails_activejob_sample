require './lib/activejob-google_cloud_tasks/router'
require './lib/activejob-google_cloud_tasks/config'

Rails.application.routes.draw do
  root 'welcome#index'

  get '/welcome', to: 'welcome#index'

  get '/job', to: 'welcome#sample_job'
  get '/job_scheduled', to: 'welcome#sample_job_scheduled'
  get '/job_multi_queue', to: 'welcome#multi_sample_job'

  mount Activejob::GoogleCloudTasks::Router, at: Activejob::GoogleCloudTasks::Config.path
end
