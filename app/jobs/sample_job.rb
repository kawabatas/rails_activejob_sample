class SampleJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    p "===== SampleJob performed."
  end
end
