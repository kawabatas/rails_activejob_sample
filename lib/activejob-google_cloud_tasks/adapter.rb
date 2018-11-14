require 'google/cloud/tasks/v2beta3'

module Activejob
  module GoogleCloudTasks
    class Adapter
      def initialize(project:, location:)
        @cloud_tasks_client = Google::Cloud::Tasks.new(version: :v2beta3)
        @project = project
        @location = location
      end

      def enqueue(job)
        Rails.logger.info("===== Activejob::GoogleCloudTasks::Adapter job: #{job.inspect}")
        Rails.logger.info("===== Activejob::GoogleCloudTasks::Adapter args: #{job.arguments.inspect}")

        formatted_parent = Google::Cloud::Tasks::V2beta3::CloudTasksClient.queue_path(@project, @location, job.queue_name)
        relative_uri = "/activejobs/execute?job=#{job.class.to_s}&#{job.arguments.to_param}"

        task = {
          app_engine_http_request: {
            http_method: :GET,
            relative_uri: relative_uri
          }
        }
        Rails.logger.info("===== Activejob::GoogleCloudTasks::Adapter task: #{task}")
        @cloud_tasks_client.create_task(formatted_parent, task)
      end

      def enqueue_at(job, timestamp)
        enqueue job, timestamp: timestamp
      end
    end
  end
end
