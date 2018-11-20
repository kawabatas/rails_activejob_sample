require "rails_helper"
require "minitest/autorun"

PROJECT = "[PROJECT]"
LOCATION = "[LOCATION]"
QUEUE = "default"

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
      ActiveJob::Base.queue_adapter = Activejob::GoogleCloudTasks::Adapter.new(project: PROJECT, location: LOCATION)
      map '/foo' do
        run Activejob::GoogleCloudTasks::Router
      end
    end.to_app
  end

  it 'can enqueue Defined Unscheduled Job' do
    formatted_parent = Google::Cloud::Tasks::V2beta3::CloudTasksClient.queue_path(PROJECT, LOCATION, QUEUE)
    # Create expected grpc response
    name = "name3373707"
    dispatch_count = 1217252086
    response_count = 424727441
    expected_response = {
      name: name,
      dispatch_count: dispatch_count,
      response_count: response_count
    }
    expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Tasks::V2beta3::Task)
    # Mock Grpc layer
    mock_method = proc do |request|
      assert_instance_of(Google::Cloud::Tasks::V2beta3::CreateTaskRequest, request)
      assert_match(/^\/foo\/execute/, request.task.app_engine_http_request.relative_uri)
      assert_nil(request.task.schedule_time)
      OpenStruct.new(execute: expected_response)
    end
    mock_stub = MockGrpcClientStub_v2beta3.new(:create_task, mock_method)
    # Mock auth layer
    mock_credentials = MockCloudTasksCredentials_v2beta3.new("create_task")

    Google::Cloud::Tasks::V2beta3::CloudTasks::Stub.stub(:new, mock_stub) do
      Google::Cloud::Tasks::V2beta3::Credentials.stub(:default, mock_credentials) do
        get '/foo/enqueue?job=FooJob'
        assert_equal(200, response.status)
      end
    end
  end

  it 'can enqueue Defined Schedule Job' do
    formatted_parent = Google::Cloud::Tasks::V2beta3::CloudTasksClient.queue_path(PROJECT, LOCATION, QUEUE)
    # Create expected grpc response
    name = "name3373707"
    dispatch_count = 1217252086
    response_count = 424727441
    expected_response = {
      name: name,
      dispatch_count: dispatch_count,
      response_count: response_count
    }
    expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Tasks::V2beta3::Task)
    # Mock Grpc layer
    mock_method = proc do |request|
      assert_instance_of(Google::Cloud::Tasks::V2beta3::CreateTaskRequest, request)
      assert_match(/^\/foo\/execute/, request.task.app_engine_http_request.relative_uri)
      assert_equal(false, request.task.schedule_time.nil?)
      OpenStruct.new(execute: expected_response)
    end
    mock_stub = MockGrpcClientStub_v2beta3.new(:create_task, mock_method)
    # Mock auth layer
    mock_credentials = MockCloudTasksCredentials_v2beta3.new("create_task")

    Google::Cloud::Tasks::V2beta3::CloudTasks::Stub.stub(:new, mock_stub) do
      Google::Cloud::Tasks::V2beta3::Credentials.stub(:default, mock_credentials) do
        get '/foo/enqueue?job=FooJob&wait_minutes=1'
        assert_equal(200, response.status)
      end
    end
  end

  it 'raises an error when enqueuing Undefined Job' do
    assert_raises(NameError){ get '/foo/enqueue?job=BarJob' }
  end

  it 'can execute Defined Job' do
    get '/foo/execute?job=FooJob'
    assert_equal(200, response.status)
  end

  it 'raises an error when executing Undefined Job' do
    assert_raises(NameError){ get '/foo/execute?job=BarJob' }
  end

  it 'handles requests other than enqueue and execute' do
    get '/foo/other?job=FooJob'
    assert_equal(404, response.status)
  end

  it 'raises an error when there is no Job parameter' do
    assert_raises(StandardError){ get '/foo/enqueue' }
  end
end
