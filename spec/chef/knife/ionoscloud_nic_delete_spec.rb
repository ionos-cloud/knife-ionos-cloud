require 'spec_helper'
require 'ionoscloud_nic_delete'

Chef::Knife::IonoscloudNicDelete.load_deps

describe Chef::Knife::IonoscloudNicDelete do
  before :each do
    subject { Chef::Knife::IonoscloudNicDelete.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call NicApi.datacenters_servers_nics_delete when the ID is valid' do
      nic = nic_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        server_id: 'server_id',
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [nic.id]

      expect(subject).to receive(:puts).with("ID: #{nic.id}")
      expect(subject).to receive(:puts).with("Name: #{nic.properties.name}")
      expect(subject).to receive(:puts).with("IPs: #{nic.properties.ips.to_s}")
      expect(subject).to receive(:puts).with("DHCP: #{nic.properties.dhcp}")
      expect(subject).to receive(:puts).with("LAN: #{nic.properties.lan}")
      expect(subject).to receive(:puts).with("NAT: #{nic.properties.nat}")
      expect(subject.ui).to receive(:warn).with("Deleted Nic #{nic.id}. Request ID: ")

      expect(subject.api_client).not_to receive(:wait_for)
      expect(subject).to receive(:get_request_id).once
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{subject_config[:server_id]}/nics/#{nic.id}",
            operation: :'NicApi.datacenters_servers_nics_find_by_id',
            return_type: 'Nic',
            result: nic,
          },
          {
            method: 'DELETE',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{subject_config[:server_id]}/nics/#{nic.id}",
            operation: :'NicApi.datacenters_servers_nics_delete',
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call NicApi.datacenters_servers_nics_delete when the user ID is not valid' do
      nic_id = 'invalid_id'
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        server_id: 'server_id',
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [nic_id]

      expect(subject.ui).to receive(:error).with("Nic ID #{nic_id} not found. Skipping.")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{subject_config[:server_id]}/nics/#{nic_id}",
            operation: :'NicApi.datacenters_servers_nics_find_by_id',
            return_type: 'Nic',
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
