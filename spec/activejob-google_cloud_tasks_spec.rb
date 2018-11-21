require "rails_helper"
require "minitest/autorun"

PROJECT = "my-project"
LOCATION = "my-location"
QUEUE = "default"
BASE_PATH = "/foo"

class FooJob < ActiveJob::Base
  queue_as QUEUE
  def perform(args)
    "hello, #{args[:name]}!"
  end
end

# Mock for the GRPC::ClientStub class.
# @see https://github.com/googleapis/google-cloud-ruby/blob/master/google-cloud-tasks/test/google/cloud/tasks/v2beta3/cloud_tasks_client_test.rb
class MockGrpcClientStub_v2beta3
  def initialize(expected_symbol, mock_method)
    @expected_symbol = expected_symbol
    @mock_method = mock_method
  end
  def method(symbol)
    return @mock_method if symbol == @expected_symbol
    proc do
      raise "The method #{symbol} was unexpectedly called during the " \
        "test for #{@expected_symbol}."
    end
  end
end

class MockCloudTasksCredentials_v2beta3 < Google::Cloud::Tasks::V2beta3::Credentials
  def initialize(method_name)
    @method_name = method_name
  end
  def updater_proc
    proc do
      raise "The method `#{@method_name}` was trying to make a grpc request. This should not " \
          "happen since the grpc layer is being mocked."
    end
  end
end

describe Activejob::GoogleCloudTasks, type: :request do
  def app
    Rack::Builder.new do
      Activejob::GoogleCloudTasks::Config.path = BASE_PATH
      ActiveJob::Base.queue_adapter = Activejob::GoogleCloudTasks::Adapter.new(project: PROJECT, location: LOCATION)
      map BASE_PATH do
        run Activejob::GoogleCloudTasks::Router
      end
    end.to_app
  end

  let(:formatted_parent) { Google::Cloud::Tasks::V2beta3::CloudTasksClient.queue_path(PROJECT, LOCATION, QUEUE) }
  let(:expected_response) {
    name = "name3373707"
    dispatch_count = 1217252086
    response_count = 424727441
    expected_response = {
      name: name,
      dispatch_count: dispatch_count,
      response_count: response_count
    }
    Google::Gax::to_proto(expected_response, Google::Cloud::Tasks::V2beta3::Task)
  }

  it 'can enqueue Defined Unscheduled Job' do
    mock_method = proc do |request|
      p "======= request Defined Unscheduled Job"
      p request

      assert_instance_of(Google::Cloud::Tasks::V2beta3::CreateTaskRequest, request)
      relative_uri = request.task.app_engine_http_request.relative_uri.dup
      relative_uri.slice!(BASE_PATH)
      assert_match(/^\/perform/, relative_uri)
      assert_nil(request.task.schedule_time)
      OpenStruct.new(execute: expected_response)
    end
    mock_stub = MockGrpcClientStub_v2beta3.new(:create_task, mock_method)
    mock_credentials = MockCloudTasksCredentials_v2beta3.new("create_task")

    Google::Cloud::Tasks::V2beta3::CloudTasks::Stub.stub(:new, mock_stub) do
      Google::Cloud::Tasks::V2beta3::Credentials.stub(:default, mock_credentials) do
        app
        FooJob.perform_later({name: 'bob'})
      end
    end
  end

  it 'can enqueue Defined Schedule Job' do
    mock_method = proc do |request|
      p "======= request Defined Scheduled Job"
      p request

      assert_instance_of(Google::Cloud::Tasks::V2beta3::CreateTaskRequest, request)
      relative_uri = request.task.app_engine_http_request.relative_uri.dup
      relative_uri.slice!(BASE_PATH)
      assert_match(/^\/perform/, relative_uri)
      assert_equal(false, request.task.schedule_time.nil?)
      OpenStruct.new(execute: expected_response)
    end
    mock_stub = MockGrpcClientStub_v2beta3.new(:create_task, mock_method)
    mock_credentials = MockCloudTasksCredentials_v2beta3.new("create_task")

    Google::Cloud::Tasks::V2beta3::CloudTasks::Stub.stub(:new, mock_stub) do
      Google::Cloud::Tasks::V2beta3::Credentials.stub(:default, mock_credentials) do
        app
        FooJob.set(wait: 1.minutes).perform_later({name: 'bob'})
      end
    end
  end

  it 'can execute Defined Job' do
    get "#{BASE_PATH}/perform?job=FooJob"
    assert_equal(200, response.status)
  end

  it 'raises an error when executing Undefined Job' do
    assert_raises(NameError){ get "#{BASE_PATH}/perform?job=BarJob" }
  end

  it 'raises an error when executing without Job parameter' do
    assert_raises(StandardError){ get "#{BASE_PATH}/perform" }
  end

  it 'handles requests other than execute' do
    get "#{BASE_PATH}/other"
    assert_equal(404, response.status)
  end
end
