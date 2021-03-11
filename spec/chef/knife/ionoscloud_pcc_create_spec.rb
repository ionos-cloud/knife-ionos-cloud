require 'spec_helper'
require 'ionoscloud_pcc_create'

Chef::Knife::IonoscloudPccCreate.load_deps

describe Chef::Knife::IonoscloudPccCreate do
  before :each do
    subject { Chef::Knife::IonoscloudPccCreate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call PrivateCrossConnectApi.pccs_post with the expected arguments and output based on what it receives' do
      pcc = pcc_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        name: pcc.properties.name,
        description: pcc.properties.description,
        peers: pcc.properties.peers.join(','),
        datacenters: pcc.properties.connectable_datacenters.join(','),
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{pcc.id}")
      expect(subject).to receive(:puts).with("Name: #{pcc.properties.name}")
      expect(subject).to receive(:puts).with("Description: #{pcc.properties.description}")
      expect(subject).to receive(:puts).with("Peers: #{pcc.properties.peers.to_s}")
      expect(subject).to receive(:puts).with("Datacenters: #{pcc.properties.connectable_datacenters.to_s}")

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: '/pccs',
            operation: :'PrivateCrossConnectApi.pccs_post',
            return_type: 'PrivateCrossConnect',
            body: { properties: { name: pcc.properties.name, description: pcc.properties.description } },
            result: pcc,
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
