require 'spec_helper'
require 'ionoscloud_request_get'

Chef::Knife::IonoscloudRequestGet.load_deps

describe Chef::Knife::IonoscloudRequestGet do
  before :each do
    subject { Chef::Knife::IonoscloudRequestGet.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call RequestsApi.requests_find_by_id' do
      request = request_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        request_id: request.id,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{request.id}")
      expect(subject).to receive(:puts).with("Status: #{request.metadata.request_status.metadata.status}")
      expect(subject).to receive(:puts).with("Method: #{request.properties.method}")
      expect(subject).to receive(:puts).with("URL: #{request.properties.url}")
      expect(subject).to receive(:puts).with("Targets: #{request.metadata.request_status.metadata.targets.map { |target| [target.target.id, target.target.type] }.to_s}")
      expect(subject).to receive(:puts).with("Body: #{request.properties.body}")
      expect(subject).to receive(:puts).with("Headers: #{request.properties.headers}")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/requests/#{request.id}",
            operation: :'RequestsApi.requests_find_by_id',
            return_type: 'Request',
            result: request,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not make any call if any required option is missing' do
      required_options = subject.instance_variable_get(:@required_options)

      if required_options.length > 0
        arrays_without_one_element(required_options).each do |test_case|
          subject.config[:ionoscloud_token] = 'token'
          test_case[:array].each { |value| subject.config[value] = 'test' }

          expect(subject).to receive(:puts).with("Missing required parameters #{test_case[:removed]}")
          expect(subject.api_client).not_to receive(:call_api)

          expect { subject.run }.to raise_error(SystemExit) do |error|
            expect(error.status).to eq(1)
          end

          required_options.each { |value| subject.config[value] = nil }
        end
      end
    end
  end
end
