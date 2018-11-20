require 'rack'

module Activejob
  module GoogleCloudTasks
    class Router
      class << self
        def call(env)
          params = Hash[URI::decode_www_form(env['QUERY_STRING'])].symbolize_keys
          raise StandardError, "Job is not specified." unless params.has_key?(:job)
          job = params[:job]

          case env['PATH_INFO']
          when /^\/enqueue/
            params_with_base_path = params.merge({base_path: env['SCRIPT_NAME']})
            if params.has_key?(:wait_minutes)
              klass(job).set(wait: params[:wait_minutes].to_i.minutes).perform_later(params_with_base_path)
            else
              klass(job).perform_later(params_with_base_path)
            end
            [200, {}, ['ok']]
          when /^\/execute/
            klass(job).perform_now(params)
            [200, {}, ['ok']]
          else
            [404, {}, ['not found']]
          end
        end

        private

        def klass(job)
          Kernel.const_get(job.camelize)
        end
      end
    end
  end
end
