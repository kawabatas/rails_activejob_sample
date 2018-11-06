class ActivejobsController < ApplicationController
  protect_from_forgery with: :null_session

  def enqueue
    Rails.logger.info('===== ActivejobsController enqueue')
    klass = params[:job].camelize.constantize
    # return head :not_found unless klass.method_defined?(:perform)

    klass.perform_later(job_args)
    head :ok
  end

  def execute
    Rails.logger.info('===== ActivejobsController execute')
    klass = params[:job].camelize.constantize

    klass.perform_now(job_args)
    head :ok
  end

  private

  def job_args
    params.require(:activejob).permit(params[:activejob].keys).to_h.symbolize_keys
  end
end
