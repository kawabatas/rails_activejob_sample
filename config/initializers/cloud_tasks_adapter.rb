require 'google/cloud/tasks/v2beta3'
require 'json'

class CloudTasksAdapter

  def initialize(project:, location:)
    @cloud_tasks_client = Google::Cloud::Tasks.new(version: :v2beta3)
    @project = project
    @location = location
  end

  def enqueue(job, attributes = {})
    Rails.logger.info("===== #{job.inspect}")
    Rails.logger.info("===== #{job.arguments.inspect}")
    Rails.logger.info("===== #{attributes.inspect}")

    formatted_parent = Google::Cloud::Tasks::V2beta3::CloudTasksClient.queue_path(@project, @location, job.queue_name)
    body = {job: job.class, activejob: job.arguments.first}

    task = {
      app_engine_http_request: {
        http_method: :POST,
        headers: { 'Content-Type' => 'application/json' },
        body: body.to_json,
        relative_uri: "/activejobs/#{job.class.to_s}/execute"
      }
    }

    @cloud_tasks_client.create_task(formatted_parent, task)
  end

  def enqueue_at(job, timestamp)
    enqueue job, timestamp: timestamp
  end
end

Rails.application.config.active_job.queue_adapter = CloudTasksAdapter.new(
  project: ENV['PROJECT'],
  location: ENV['LOCATION']
)
