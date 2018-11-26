require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RailsActivejobSample
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # stackdriver
    config.google_cloud.use_error_reporting = Rails.env.production?
    config.google_cloud.use_debugger = Rails.env.production?
    config.google_cloud.use_logging = Rails.env.production?
    config.google_cloud.use_trace = Rails.env.production?

    config.active_job.queue_adapter = Activejob::GoogleCloudTasks::Adapter.new(
      project: ENV['GOOGLE_CLOUD_TASKS_PROJECT'],
      location: ENV['GOOGLE_CLOUD_TASKS_LOCATION'],
    )
  end
end
