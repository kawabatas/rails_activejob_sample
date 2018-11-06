class SampleJob < ApplicationJob
  queue_as :default

  def perform(params)
    # Do something later
    Rails.logger.info("===== SampleJob performed. #{params.inspect}")
  end
end
