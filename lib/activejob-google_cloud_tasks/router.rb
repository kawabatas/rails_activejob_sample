require 'rack'

module Activejob
  module GoogleCloudTasks
    class Router
      class << self
        def call(env)
          Rails.logger.info("===== start Activejob::GoogleCloudTasks::Router")
          Rails.logger.info("========== #{env.keys}")
          Rails.logger.info("========== REQUEST_METHOD: #{env['REQUEST_METHOD']}")
          Rails.logger.info("========== REQUEST_PATH: #{env['REQUEST_PATH']}")
          Rails.logger.info("========== REQUEST_URI: #{env['REQUEST_URI']}")
          Rails.logger.info("========== PATH_INFO: #{env['PATH_INFO']}")
          Rails.logger.info("========== rack.input: #{env['rack.input'].gets}")

          params = Hash[URI::decode_www_form(URI.parse(env['REQUEST_URI']).query)].symbolize_keys
          job = params[:job]
          args = params.except(:job)

          Rails.logger.info("========== params: #{params}")

          if env['PATH_INFO'].match(/^\/enqueue/)
            enqueue(job, args)
          elsif env['PATH_INFO'].match(/^\/execute/)
            execute(job, args)
          else
            [404, {}, ['not found']]
          end

        end

        def enqueue(job, args)
          Rails.logger.info("===== enqueue !!! job: #{job}=====")
          job_performer {
            klass = klass(job)
            klass.perform_later(args)
            # klass.set(wait_until: Date.tomorrow.noon).perform_later(args)
          }
        end

        def execute(job, args)
          Rails.logger.info("===== execute !!! job: #{job} =====")
          job_performer {
            klass = klass(job)
            klass.perform_now(args)
          }
        end

        private

        def job_performer
          begin
            yield
            [200, {}, ['ok']]
          rescue
            [404, {}, ['not found']]
          end
        end

        def klass(job)
          Kernel.const_get(job.camelize)
        end

      end
    end
  end
end
