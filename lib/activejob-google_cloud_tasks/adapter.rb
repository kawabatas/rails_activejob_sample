require 'google/cloud/tasks/v2beta3'

module Activejob
  module GoogleCloudTasks
    class Adapter
      def initialize(project:, location:, logger: Logger.new($stdout))
        @cloud_tasks_client = Google::Cloud::Tasks.new(version: :v2beta3)
        @project = project
        @location = location
        @logger = logger
      end

      def enqueue(job)
        @logger&.info("===== Activejob::GoogleCloudTasks::Adapter job: #{job.inspect}")
        @logger&.info("===== Activejob::GoogleCloudTasks::Adapter args: #{job.arguments.inspect}")

        formatted_parent = Google::Cloud::Tasks::V2beta3::CloudTasksClient.queue_path(@project, @location, job.queue_name)
        relative_uri = "#{job.arguments.first[:base_path]}/execute?job=#{job.class.to_s}&#{job.arguments.to_param}"

        task = {
          app_engine_http_request: {
            http_method: :GET,
            relative_uri: relative_uri
          }
        }
        @logger&.info("===== Activejob::GoogleCloudTasks::Adapter task: #{task}")
        @cloud_tasks_client.create_task(formatted_parent, task)
      end

      def enqueue_at(job, timestamp)
        raise NotImplementedError, "This queueing backend does not support scheduling jobs."
      end
    end
  end
end
