require 'spec_helper'
require 'ionoscloud_lan_update'

Chef::Knife::IonoscloudLanUpdate.load_deps

describe Chef::Knife::IonoscloudLanUpdate do
  before :each do
    subject { Chef::Knife::IonoscloudLanUpdate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call LanApi.datacenters_lans_patch' do
      lan = lan_mock
      uuid = SecureRandom.uuid
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        lan_id: lan.id,
        name: lan.properties.name + '_edited',
        public: (!lan.properties.public).to_s,
        ip_failover: [{ 'ip' => '1.1.1.1', 'nic_uuid' => uuid }],
        pcc: 'pcc_id',
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{lan.id}")
      expect(subject).to receive(:puts).with("Name: #{subject_config[:name]}")
      expect(subject).to receive(:puts).with("Public: #{subject_config[:public]}")
      expect(subject).to receive(:puts).with("PCC: #{subject_config[:pcc]}")
      expect(subject).to receive(:puts).with("IP Failover: #{[{ ip: '1.1.1.1', nicUuid: uuid }]}")

      lan.properties.name = subject_config[:name]
      lan.properties.public = subject_config[:public].to_s.downcase == 'true'
      lan.properties.pcc = subject_config[:pcc]
      lan.properties.ip_failover = [Ionoscloud::IPFailover.new(ip: '1.1.1.1', nic_uuid: uuid)]

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'PATCH',
            path: "/datacenters/#{subject_config[:datacenter_id]}/lans/#{subject_config[:lan_id]}",
            operation: :'LanApi.datacenters_lans_patch',
            return_type: 'Lan',
            body: {
              name: subject_config[:name],
              public: subject_config[:public].to_s.downcase == 'true',
              pcc: subject_config[:pcc],
              ipFailover: [{ ip: '1.1.1.1', nicUuid: uuid }],
            },
            result: lan,
          },
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/lans/#{subject_config[:lan_id]}",
            operation: :'LanApi.datacenters_lans_find_by_id',
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
