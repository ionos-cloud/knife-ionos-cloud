require 'spec_helper'
require 'ionoscloud_request_wait'

Chef::Knife::IonoscloudRequestWait.load_deps

describe Chef::Knife::IonoscloudRequestWait do
  subject { Chef::Knife::IonoscloudRequestWait.new }

  describe '#run' do
    it 'should call api_client.wait_for' do
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        request_id: 'request_id',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      allow(subject).to receive(:puts)
      allow(subject).to receive(:print)

      expect(subject).to receive(:is_done?).once do |arg|
        expect(arg).to eql(subject_config[:request_id])
        true
      end

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should output an error is the request is not found' do
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        request_id: 'request_id',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      allow(subject).to receive(:puts)
      allow(subject).to receive(:print)

      expect(subject.ui).to receive(:error).with("Request ID #{subject_config[:request_id]} not found.")

      expect(subject).to receive(:is_done?).once do |arg|
        expect(arg).to eql(subject_config[:request_id])
        raise Ionoscloud::ApiError.new(code: 404)
      end

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not make any call if any required option is missing' do
      required_options = subject.instance_variable_get(:@required_options)
      allow(subject).to receive(:puts)
      allow(subject).to receive(:print)

      arrays_without_one_element(required_options).each do |test_case|
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
