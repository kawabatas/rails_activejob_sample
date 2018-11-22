class WelcomeController < ApplicationController
  def index
  end

  def sample_job
    SampleJob.set(wait: 1.minutes).perform_later({name: 'ken', email: 'ken@example.com'})
    head :ok
  end
end
