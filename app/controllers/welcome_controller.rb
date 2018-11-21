class WelcomeController < ApplicationController
  def index
  end

  def sample_job
    SampleJob.perform_later({name: 'bob', email: 'bob@example.com'})
    head :ok
  end

  def sample_job_scheduled
    SampleJob.set(wait: 1.minutes).perform_later({name: 'bob', email: 'bob@example.com'})
    head :ok
  end

  def multi_sample_job
    MultiSampleJob.perform_later({name: 'multi bob', email: 'multibob@example.com'})
    head :ok
  end
end
