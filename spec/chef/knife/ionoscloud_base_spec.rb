require 'ionoscloud'

require 'spec_helper'
require 'ionoscloud_base'

class Chef
  class Knife
    class IonoscloudBaseTest < Knife
      include Knife::IonoscloudBase
    end
  end
end

describe Chef::Knife::IonoscloudBaseTest do
  before :each do
    subject { Chef::Knife::IonoscloudBaseTest.new }
  end

  describe '#is_done' do
    it 'should return true when request status is DONE' do
      request_status = request_status_mock
      request_id = SecureRandom.uuid

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/requests/#{request_id}/status",
            operation: :'RequestsApi.requests_status_get',
            return_type: 'RequestStatus',
            result: request_status,
          },
        ],
      )

      expect(subject.is_done? request_id).to eql(true)
    end

    it 'should return false when request status is QUEUED' do
      request_status = request_status_mock({ status: 'QUEUED' })
      request_id = SecureRandom.uuid

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/requests/#{request_id}/status",
            operation: :'RequestsApi.requests_status_get',
            return_type: 'RequestStatus',
            result: request_status,
          },
        ],
      )

      expect(subject.is_done? request_id).to eql(false)
    end

    it 'should return false when request status is RUNNING' do
      request_status = request_status_mock({ status: 'RUNNING' })
      request_id = SecureRandom.uuid

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/requests/#{request_id}/status",
            operation: :'RequestsApi.requests_status_get',
            return_type: 'RequestStatus',
            result: request_status,
          },
        ],
      )

      expect(subject.is_done? request_id).to eql(false)
    end

    it 'should return false when request status is FAILED' do
      request_status = request_status_mock({ status: 'FAILED' })
      request_id = SecureRandom.uuid

      expect(subject).to receive(:puts).with("\nRequest #{request_id} failed\n#{request_status.metadata.message.to_s}")

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/requests/#{request_id}/status",
            operation: :'RequestsApi.requests_status_get',
            return_type: 'RequestStatus',
            result: request_status,
          },
        ],
      )

      expect { subject.is_done? request_id }.to raise_error(SystemExit) do |error|
        expect(error.status).to eq(1)
      end
    end
  end

  describe '#get_request_id' do
    it 'should return nil when Headers has no Location key' do
      headers = {
        'another_key' => '/requests/123',
      }

      expect(subject.get_request_id headers).to be_nil
    end

    it 'should return nil when Headers[\'Location\'] contains no uuid' do
      headers = {
        'Location' => '/requests/123',
      }

      expect(subject.get_request_id headers).to be_nil
    end

    it 'should extract the ID from the headers' do
      request_id = SecureRandom.uuid
      headers = {
        'Location' => "/requests/#{request_id}",
      }

      expect(subject.get_request_id headers).to eql(request_id)
    end
  end

  describe '#validate_required_params' do
    it 'should do nothing when all required params are in params' do
      required_params = [:param1, :param2]
      params = {
        ionoscloud_token: 'token',
        param1: 'value',
        param2: 'value',
      }

      expect { subject.validate_required_params(required_params, params) }.not_to raise_error(Exception)
    end

    it 'should raise an exception and output the missing params when there are missing params' do
      required_params = [:param1, :param2]
      params = {
        ionoscloud_token: 'token',
        param1: 'value',
      }

      expect(subject).to receive(:puts).with("Missing required parameters #{[:param2]}")

      expect { subject.validate_required_params(required_params, params) }.to raise_error(SystemExit) do |error|
        expect(error.status).to eq(1)
      end
    end

    it 'should raise an exception when no auth method is supplied' do
      required_params = []
      params = {
        param1: 'value',
      }

      expect(subject).to receive(:puts).with(
        'Either ionoscloud_token or ionoscloud_username and ionoscloud_password must be provided to access the Ionoscloud API',
      )

      expect { subject.validate_required_params(required_params, params) }.to raise_error(SystemExit) do |error|
        expect(error.status).to eq(1)
      end
    end

    it 'should raise an exception when no auth method is supplied correctly' do
      required_params = []
      params = {
        param1: 'value',
        ionoscloud_user: 'value',
      }

      expect(subject).to receive(:puts).with(
        'Either ionoscloud_token or ionoscloud_username and ionoscloud_password must be provided to access the Ionoscloud API',
      )

      expect { subject.validate_required_params(required_params, params) }.to raise_error(SystemExit) do |error|
        expect(error.status).to eq(1)
      end
    end

    it 'should raise an exception when no auth method is supplied correctly 2' do
      required_params = []
      params = {
        param1: 'value',
        ionoscloud_password: 'value',
      }

      expect(subject).to receive(:puts).with(
        'Either ionoscloud_token or ionoscloud_username and ionoscloud_password must be provided to access the Ionoscloud API',
      )

      expect { subject.validate_required_params(required_params, params) }.to raise_error(SystemExit) do |error|
        expect(error.status).to eq(1)
      end
    end
  end
end
