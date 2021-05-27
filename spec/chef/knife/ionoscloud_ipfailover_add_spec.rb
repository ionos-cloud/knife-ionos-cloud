require 'spec_helper'
require 'ionoscloud_ipfailover_add'

Chef::Knife::IonoscloudIpfailoverAdd.load_deps

describe Chef::Knife::IonoscloudIpfailoverAdd do
  before :each do
    subject { Chef::Knife::IonoscloudIpfailoverAdd.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call Lan.datacenters_lans_patch when the ID is valid' do
      lan = lan_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        lan_id: lan.id,
        nic_id: 'nic_id',
        ip: '1.1.1.1',
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{lan.id}")
      expect(subject).to receive(:puts).with("Name: #{lan.properties.name}")
      expect(subject).to receive(:puts).with("Public: #{lan.properties.public.to_s}")
      expect(subject).to receive(:puts).with("IP Failover: #{[{ ip: subject_config[:ip], nicUuid: subject_config[:nic_id] }]}")

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/lans/#{lan.id}",
            operation: :'LansApi.datacenters_lans_find_by_id',
            return_type: 'Lan',
            result: lan,
          },
          {
            method: 'PATCH',
            path: "/datacenters/#{subject_config[:datacenter_id]}/lans/#{lan.id}",
            operation: :'LansApi.datacenters_lans_patch',
            body: Ionoscloud::LanProperties.new({ ip_failover: [({ ip: subject_config[:ip], nicUuid: subject_config[:nic_id] })] }).to_hash,
            return_type: 'Lan',
          },
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/lans/#{lan.id}",
            operation: :'LansApi.datacenters_lans_find_by_id',
            return_type: 'Lan',
            result: lan,
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
