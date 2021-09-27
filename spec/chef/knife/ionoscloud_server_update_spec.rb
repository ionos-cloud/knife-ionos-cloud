require 'spec_helper'
require 'ionoscloud_server_update'

Chef::Knife::IonoscloudServerUpdate.load_deps

describe Chef::Knife::IonoscloudServerUpdate do
  before :each do
    subject { Chef::Knife::IonoscloudServerUpdate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call ServerApi.datacenters_servers_patch' do
      server = server_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        server_id: server.id,
        name: server.properties.name + '_edited',
        cores: server.properties.cores + 1,
        cpu_family: 'AMD_OPTERON',
        ram: server.properties.ram * 2,
        availability_zone: 'AUTO',
        boot_volume: SecureRandom.uuid,
        boot_cdrom: SecureRandom.uuid,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{server.id}")
      expect(subject).to receive(:puts).with("Name: #{subject_config[:name]}")
      expect(subject).to receive(:puts).with("Cores: #{subject_config[:cores]}")
      expect(subject).to receive(:puts).with("CPU Family: #{subject_config[:cpu_family]}")
      expect(subject).to receive(:puts).with("Ram: #{subject_config[:ram]}")
      expect(subject).to receive(:puts).with("Availability Zone: #{subject_config[:availability_zone]}")
      expect(subject).to receive(:puts).with("Boot Volume: #{subject_config[:boot_volume]}")
      expect(subject).to receive(:puts).with("Boot CDROM: #{subject_config[:boot_cdrom]}")

      server.properties.name = subject_config[:name]
      server.properties.cores = subject_config[:cores]
      server.properties.cpu_family = subject_config[:cpu_family]
      server.properties.ram = subject_config[:ram]
      server.properties.availability_zone = subject_config[:availability_zone]
      server.properties.boot_volume = Ionoscloud::ResourceReference.new(id: subject_config[:boot_volume])
      server.properties.boot_cdrom = Ionoscloud::ResourceReference.new(id: subject_config[:boot_cdrom])

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'PATCH',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{subject_config[:server_id]}",
            operation: :'ServerApi.datacenters_servers_patch',
            return_type: 'Server',
            body: {
              name: subject_config[:name],
              cores: subject_config[:cores],
              cpuFamily: subject_config[:cpu_family],
              ram: subject_config[:ram],
              availabilityZone: subject_config[:availability_zone],
              bootVolume: { id: subject_config[:boot_volume] },
              bootCdrom: { id: subject_config[:boot_cdrom] },
            },
            result: server,
          },
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{subject_config[:server_id]}",
            operation: :'ServerApi.datacenters_servers_find_by_id',
            return_type: 'Server',
            result: server,
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
