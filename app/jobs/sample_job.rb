class SampleJob < ApplicationJob
  queue_as :default

  def perform(args)
    # Do something later
    Rails.logger.info("===== SampleJob performed. #{args.inspect}")
  end
end
