require 'spec_helper'
require 'ionoscloud_request_status'

Chef::Knife::IonoscloudRequestStatus.load_deps

describe Chef::Knife::IonoscloudRequestStatus do
  subject { Chef::Knife::IonoscloudRequestStatus.new }

  describe '#run' do
    it 'should call RequestsApi.requests_status_get and output the received status when the request ID is valid' do
      request_status = request_status_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        request_id: 'request_id',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      allow(subject).to receive(:puts)

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/requests/#{subject_config[:request_id]}/status",
            operation: :'RequestsApi.requests_status_get',
            return_type: 'RequestStatus',
            result: request_status,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should output an error is the request is not found' do
      request_id = 'invalid_id'
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        request_id: request_id,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      allow(subject).to receive(:puts)
      allow(subject).to receive(:print)

      expect(subject.ui).to receive(:error).with("Request ID #{request_id} not found.")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/requests/#{request_id}/status",
            operation: :'RequestsApi.requests_status_get',
            return_type: 'RequestStatus',
            exception: Ionoscloud::ApiError.new(code: 404),
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not make any call if any required option is missing' do
      check_required_options(subject)
    end
  end
end
