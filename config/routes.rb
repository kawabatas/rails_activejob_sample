Rails.application.routes.draw do
  root 'welcome#index'

  get '/welcome', to: 'welcome#index'

  post '/activejobs/:job/enqueue', to: 'activejobs#enqueue'
  post '/activejobs/:job/execute', to: 'activejobs#execute'
end
