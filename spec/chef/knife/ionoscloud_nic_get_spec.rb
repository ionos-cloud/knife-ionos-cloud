require 'spec_helper'
require 'ionoscloud_nic_get'

Chef::Knife::IonoscloudNicGet.load_deps

describe Chef::Knife::IonoscloudNicGet do
  before :each do
    subject { Chef::Knife::IonoscloudNicGet.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call NicApi.datacenters_servers_nics_find_by_id' do
      nic = nic_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        server_id: 'server_id',
        nic_id: nic.id,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{nic.id}")
      expect(subject).to receive(:puts).with("Name: #{nic.properties.name}")
      expect(subject).to receive(:puts).with("IPs: #{nic.properties.ips.to_s}")
      expect(subject).to receive(:puts).with("DHCP: #{nic.properties.dhcp}")
      expect(subject).to receive(:puts).with("LAN: #{nic.properties.lan}")
      expect(subject).to receive(:puts).with("NAT: #{nic.properties.nat}")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{subject_config[:server_id]}/nics/#{subject_config[:nic_id]}",
            operation: :'NicApi.datacenters_servers_nics_find_by_id',
            return_type: 'Nic',
            result: nic,
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
