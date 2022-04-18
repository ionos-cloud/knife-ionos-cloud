require 'spec_helper'
require 'ionoscloud_pcc_delete'

Chef::Knife::IonoscloudPccDelete.load_deps

describe Chef::Knife::IonoscloudPccDelete do
  before :each do
    subject { Chef::Knife::IonoscloudPccDelete.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call PrivateCrossConnectsApi.pccs_delete when the ID is valid' do
      pcc = pcc_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [pcc.id]

      peers = pcc.properties.peers.map { |peer| peer.id }
      datacenters = pcc.properties.connectable_datacenters.map { |pcc| pcc.id }

      expect(subject).to receive(:puts).with("ID: #{pcc.id}")
      expect(subject).to receive(:puts).with("Name: #{pcc.properties.name}")
      expect(subject).to receive(:puts).with("Description: #{pcc.properties.description}")
      expect(subject).to receive(:puts).with("Peers: #{peers.to_s}")
      expect(subject).to receive(:puts).with("Connectable Datacenters: #{datacenters.to_s}")
      expect(subject.ui).to receive(:warn).with("Deleted PCC #{pcc.id}. Request ID: ")

      expect(subject.api_client).not_to receive(:wait_for)
      expect(subject).to receive(:get_request_id).once
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/pccs/#{pcc.id}",
            operation: :'PrivateCrossConnectsApi.pccs_find_by_id',
            return_type: 'PrivateCrossConnect',
            result: pcc,
          },
          {
            method: 'DELETE',
            path: "/pccs/#{pcc.id}",
            operation: :'PrivateCrossConnectsApi.pccs_delete',
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call PrivateCrossConnectsApi.pccs_delete when the ID is not valid' do
      pcc_id = 'invalid_id'
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [pcc_id]

      expect(subject.ui).to receive(:error).with("PCC ID #{pcc_id} not found. Skipping.")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/pccs/#{pcc_id}",
            operation: :'PrivateCrossConnectsApi.pccs_find_by_id',
            return_type: 'PrivateCrossConnect',
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
