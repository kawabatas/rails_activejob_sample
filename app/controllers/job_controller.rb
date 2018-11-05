class JobController < ApplicationController
  def index
    SampleJob.perform_later('test')

    head :ok
  end
end
