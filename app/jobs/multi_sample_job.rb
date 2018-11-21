class MultiSampleJob < ApplicationJob
  queue_as :test

  def perform(args)
    # Do something later
    Rails.logger.info("===== MultiSampleJob performed. #{args.inspect}")
  end
end
