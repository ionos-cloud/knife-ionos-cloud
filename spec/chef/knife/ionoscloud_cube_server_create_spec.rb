require 'spec_helper'
require 'ionoscloud_cube_server_create'

Chef::Knife::IonoscloudCubeServerCreate.load_deps

describe Chef::Knife::IonoscloudCubeServerCreate do
  before :each do
    subject { Chef::Knife::IonoscloudCubeServerCreate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call ServersApi.datacenters_servers_post with the expected arguments and also make another call to set the boot_volume when set_boot is sent' do
      template = template_mock
      server = server_mock(
        volumes: Ionoscloud::Volumes.new(items: [volume_mock(size: template.properties.storage_size, type: 'DAS')]),
        nics: Ionoscloud::Nics.new(items: [nic_mock]),
        ram: template.properties.ram,
        cores: template.properties.cores,
        boot_volume: nil,
        boot_cdrom: Ionoscloud::ResourceReference.new({ id: nil }),
      )

      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',

        template: template.id,
        name: server.properties.name,
        cpu_family: server.properties.cpu_family,
        availability_zone: server.properties.availability_zone,

        volume_name: server.entities.volumes.items.first.properties.name,
        type: server.entities.volumes.items.first.properties.type,
        bus: server.entities.volumes.items.first.properties.bus,
        image: SecureRandom.uuid,
        image_password: 'K3tTj8G14a3EgKyNeeiY',
        backupunit_id: server.entities.volumes.items.first.properties.backupunit_id,
        user_data: server.entities.volumes.items.first.properties.user_data,

        set_boot: true,

        lan: server.entities.nics.items.first.properties.lan,
        nic_name: server.entities.nics.items.first.properties.name,
        dhcp: server.entities.nics.items.first.properties.dhcp,
        ips: server.entities.nics.items.first.properties.ips.join(','),
        firewall_type: server.entities.nics.items.first.properties.firewall_type,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{server.id}")
      expect(subject).to receive(:puts).with("Name: #{server.properties.name}")
      expect(subject).to receive(:puts).with("Type: #{server.properties.type}")
      expect(subject).to receive(:puts).with("Cores: #{server.properties.cores}")
      expect(subject).to receive(:puts).with("CPU Family: #{server.properties.cpu_family}")
      expect(subject).to receive(:puts).with("Ram: #{server.properties.ram}")
      expect(subject).to receive(:puts).with("Availability Zone: #{server.properties.availability_zone}")
      expect(subject).to receive(:puts).with("Boot Volume: #{server.entities.volumes.items.first.id}")
      expect(subject).to receive(:puts).with("Boot CDROM: ")

      expected_properties = server.properties.to_hash
      expected_properties.delete(:bootCdrom)
      expected_properties.delete(:bootVolume)
      expected_properties.delete(:cores)
      expected_properties.delete(:ram)
      expected_properties[:type] = 'CUBE'
      expected_properties[:templateUuid] = template.id

      expected_entities = server.entities.to_hash
      expected_entities[:volumes][:items][0].delete(:id)
      expected_entities[:volumes][:items][0][:properties].delete(:size)
      expected_entities[:volumes][:items][0][:properties].delete(:availabilityZone)
      expected_entities[:nics][:items][0].delete(:id)
      expected_entities[:nics][:items][0].delete(:entities)
      expected_entities[:nics][:items][0][:properties].delete(:mac)
      expected_entities[:nics][:items][0][:properties].delete(:firewallActive)

      expected_entities[:volumes][:items][0][:properties].delete(:licenceType)
      expected_entities[:volumes][:items][0][:properties][:image] = subject_config[:image]
      expected_entities[:volumes][:items][0][:properties][:imagePassword] = subject_config[:image_password]

      server.properties.boot_volume = Ionoscloud::ResourceReference.new({ id: server.entities.volumes.items.first.id })

      mock_wait_for(subject)
      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers",
            operation: :'ServersApi.datacenters_servers_post',
            return_type: 'Server',
            body: { properties: expected_properties, entities: expected_entities },
            result: server,
          },
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{server.id}",
            operation: :'ServersApi.datacenters_servers_find_by_id',
            return_type: 'Server',
            result: server,
          },
          {
            method: 'PATCH',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{server.id}",
            operation: :'ServersApi.datacenters_servers_patch',
            return_type: 'Server',
            body: { bootVolume: { id: server.entities.volumes.items[0].id } },
            result: server,
          },
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{server.id}",
            operation: :'ServersApi.datacenters_servers_find_by_id',
            return_type: 'Server',
            result: server,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should call ServersApi.datacenters_servers_post with the expected arguments and should not make another call to set the boot_volume when set_boot is not sent' do
      template = template_mock
      server = server_mock(
        volumes: Ionoscloud::Volumes.new(items: [volume_mock(size: template.properties.storage_size, type: 'DAS')]),
        nics: Ionoscloud::Nics.new(items: [nic_mock]),
        ram: template.properties.ram,
        cores: template.properties.cores,
        boot_volume: nil,
        boot_cdrom: Ionoscloud::ResourceReference.new({ id: nil }),
      )

      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',

        template: template.id,
        name: server.properties.name,
        cpu_family: server.properties.cpu_family,
        availability_zone: server.properties.availability_zone,

        volume_name: server.entities.volumes.items.first.properties.name,
        type: server.entities.volumes.items.first.properties.type,
        bus: server.entities.volumes.items.first.properties.bus,
        image: SecureRandom.uuid,
        image_password: 'K3tTj8G14a3EgKyNeeiY',
        backupunit_id: server.entities.volumes.items.first.properties.backupunit_id,
        user_data: server.entities.volumes.items.first.properties.user_data,

        set_boot: false,

        lan: server.entities.nics.items.first.properties.lan,
        nic_name: server.entities.nics.items.first.properties.name,
        dhcp: server.entities.nics.items.first.properties.dhcp,
        ips: server.entities.nics.items.first.properties.ips.join(','),
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{server.id}")
      expect(subject).to receive(:puts).with("Name: #{server.properties.name}")
      expect(subject).to receive(:puts).with("Type: #{server.properties.type}")
      expect(subject).to receive(:puts).with("Cores: #{server.properties.cores}")
      expect(subject).to receive(:puts).with("CPU Family: #{server.properties.cpu_family}")
      expect(subject).to receive(:puts).with("Ram: #{server.properties.ram}")
      expect(subject).to receive(:puts).with("Availability Zone: #{server.properties.availability_zone}")
      expect(subject).to receive(:puts).with("Boot Volume: #{server.entities.volumes.items.first.id}")
      expect(subject).to receive(:puts).with("Boot CDROM: ")

      expected_properties = server.properties.to_hash
      expected_properties.delete(:bootCdrom)
      expected_properties.delete(:bootVolume)
      expected_properties.delete(:cores)
      expected_properties.delete(:ram)
      expected_properties[:type] = 'CUBE'
      expected_properties[:templateUuid] = template.id

      expected_entities = server.entities.to_hash
      expected_entities[:volumes][:items][0].delete(:id)
      expected_entities[:volumes][:items][0][:properties].delete(:size)
      expected_entities[:volumes][:items][0][:properties].delete(:availabilityZone)
      expected_entities[:nics][:items][0].delete(:id)
      expected_entities[:nics][:items][0].delete(:entities)
      expected_entities[:nics][:items][0][:properties].delete(:mac)
      expected_entities[:nics][:items][0][:properties].delete(:firewallActive)

      expected_entities[:volumes][:items][0][:properties].delete(:licenceType)
      expected_entities[:volumes][:items][0][:properties][:image] = subject_config[:image]
      expected_entities[:volumes][:items][0][:properties][:imagePassword] = subject_config[:image_password]

      server.properties.boot_volume = Ionoscloud::ResourceReference.new({ id: server.entities.volumes.items.first.id })

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers",
            operation: :'ServersApi.datacenters_servers_post',
            return_type: 'Server',
            body: { properties: expected_properties, entities: expected_entities },
            result: server,
          },
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{server.id}",
            operation: :'ServersApi.datacenters_servers_find_by_id',
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
