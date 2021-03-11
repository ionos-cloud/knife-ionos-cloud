require 'spec_helper'
require 'ionoscloud_ipblock_delete'

Chef::Knife::IonoscloudIpblockDelete.load_deps

describe Chef::Knife::IonoscloudIpblockDelete do
  before :each do
    subject { Chef::Knife::IonoscloudIpblockDelete.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call IPBlocksApi.ipblocks_delete when the ID is valid' do
      ipblock = ipblock_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [ipblock.id]

      expect(subject).to receive(:puts).with("ID: #{ipblock.id}")
      expect(subject).to receive(:puts).with("Name: #{ipblock.properties.name}")
      expect(subject).to receive(:puts).with("IP Addresses: #{ipblock.properties.ips.to_s}")
      expect(subject).to receive(:puts).with("Location: #{ipblock.properties.location}")
      expect(subject.ui).to receive(:warn).with("Released IP block #{ipblock.id}. Request ID: ")

      expect(subject.api_client).not_to receive(:wait_for)
      expect(subject).to receive(:get_request_id).once
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/ipblocks/#{ipblock.id}",
            operation: :'IPBlocksApi.ipblocks_find_by_id',
            return_type: 'IpBlock',
            result: ipblock,
          },
          {
            method: 'DELETE',
            path: "/ipblocks/#{ipblock.id}",
            operation: :'IPBlocksApi.ipblocks_delete',
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call IPBlocksApi.ipblocks_delete when the user ID is not valid' do
      ipblock_id = 'invalid_id'
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [ipblock_id]

      expect(subject.ui).to receive(:error).with("IP block ID #{ipblock_id} not found. Skipping.")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/ipblocks/#{ipblock_id}",
            operation: :'IPBlocksApi.ipblocks_find_by_id',
            return_type: 'IpBlock',
            exception: Ionoscloud::ApiError.new(code: 404),
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not make any call if any required option is missing' do
      required_options = subject.instance_variable_get(:@required_options)

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
