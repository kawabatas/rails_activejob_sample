class JobController < ApplicationController
  def index
    # SampleJob.perform_later('test')
    Rails.logger.info('===== JobController index')

    head :ok
  end
end
