require 'rack'

module Activejob
  module GoogleCloudTasks
    class Router
      class << self
        def call(env)
          params = Hash[URI::decode_www_form(env['QUERY_STRING'])].symbolize_keys
          job = params[:job]
          base_path = env['REQUEST_URI'].chomp("#{env['PATH_INFO']}?#{env['QUERY_STRING']}")
          args = params.except(:job).merge({base_path: base_path})

          case env['PATH_INFO']
          when /^\/enqueue/
            if params.has_key?(:wait_minutes)
              klass(job).set(wait: params[:wait_minutes].to_i.minutes).perform_later(args)
            else
              klass(job).perform_later(args)
            end
            [200, {}, ['ok']]
          when /^\/execute/
            klass(job).perform_now(args)
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
