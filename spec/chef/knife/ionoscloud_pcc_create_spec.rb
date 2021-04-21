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
      datacenter_ids = pcc.properties.connectable_datacenters.map { |datacenter| datacenter.id}
      lan_ids = pcc.properties.peers.map { |peer| peer.id }
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        name: pcc.properties.name,
        description: pcc.properties.description,
        peers: datacenter_ids.zip(lan_ids).flatten.compact.join(','),
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{pcc.id}")
      expect(subject).to receive(:puts).with("Name: #{pcc.properties.name}")
      expect(subject).to receive(:puts).with("Description: #{pcc.properties.description}")
      expect(subject).to receive(:puts).with("Peers: #{pcc.properties.peers.to_s}")
      expect(subject).to receive(:puts).with("Datacenters: #{pcc.properties.connectable_datacenters.to_s}")

      3.times { mock_wait_for(subject) }
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
          {
            method: 'GET',
            path: "/pccs/#{pcc.id}",
            operation: :'PrivateCrossConnectApi.pccs_find_by_id',
            return_type: 'PrivateCrossConnect',
            result: pcc,
          },
          {
            method: 'PATCH',
            path: "/datacenters/#{pcc.properties.connectable_datacenters[0].id}/lans/#{pcc.properties.peers[0].id}",
            operation: :'LanApi.datacenters_lans_patch',
            return_type: 'Lan',
            body: { pcc: pcc.id },
            result: pcc.properties.peers[0],
          },
          {
            method: 'PATCH',
            path: "/datacenters/#{pcc.properties.connectable_datacenters[1].id}/lans/#{pcc.properties.peers[1].id}",
            operation: :'LanApi.datacenters_lans_patch',
            return_type: 'Lan',
            body: { pcc: pcc.id },
            result: pcc.properties.peers[1],
          },
          {
            method: 'GET',
            path: "/pccs/#{pcc.id}",
            operation: :'PrivateCrossConnectApi.pccs_find_by_id',
            return_type: 'PrivateCrossConnect',
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
