require 'spec_helper'
require 'ionoscloud_composite_server_create'

Chef::Knife::IonoscloudCompositeServerCreate.load_deps

describe Chef::Knife::IonoscloudCompositeServerCreate do
  before :each do
    subject { Chef::Knife::IonoscloudCompositeServerCreate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call ServersApi.datacenters_servers_post with the expected arguments and output based on what it receives' do
      server = server_mock({ volumes: Ionoscloud::Volumes.new(items: [volume_mock]), nics: Ionoscloud::Nics.new(items: [nic_mock]) })
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',

        name: server.properties.name,
        cores: server.properties.cores,
        cpu_family: server.properties.cpu_family,
        ram: server.properties.ram,
        availability_zone: server.properties.availability_zone,

        volume_name: server.entities.volumes.items.first.properties.name,
        size: server.entities.volumes.items.first.properties.size,
        type: server.entities.volumes.items.first.properties.type,
        bus: server.entities.volumes.items.first.properties.bus,
        volume_availability_zone: server.entities.volumes.items.first.properties.availability_zone,
        licence_type: server.entities.volumes.items.first.properties.licence_type,
        image: SecureRandom.uuid,
        image_password: 'K3tTj8G14a3EgKyNeeiY',

        lan: server.entities.nics.items.first.properties.lan,
        nic_name: server.entities.nics.items.first.properties.name,
        dhcp: server.entities.nics.items.first.properties.dhcp,
        ips: server.entities.nics.items.first.properties.ips.join(','),
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{server.id}")
      expect(subject).to receive(:puts).with("Name: #{server.properties.name}")
      expect(subject).to receive(:puts).with("Cores: #{server.properties.cores}")
      expect(subject).to receive(:puts).with("CPU Family: #{server.properties.cpu_family}")
      expect(subject).to receive(:puts).with("Ram: #{server.properties.ram}")
      expect(subject).to receive(:puts).with("Availability Zone: #{server.properties.availability_zone}")

      expected_properties = server.properties.to_hash
      expected_properties.delete(:bootCdrom)
      expected_properties.delete(:bootVolume)

      expected_entities = server.entities.to_hash
      expected_entities[:volumes][:items][0].delete(:id)
      expected_entities[:nics][:items][0].delete(:id)
      expected_entities[:nics][:items][0].delete(:entities)
      expected_entities[:nics][:items][0][:properties].delete(:mac)
      expected_entities[:nics][:items][0][:properties].delete(:firewallActive)

      expected_entities[:volumes][:items][0][:properties][:image] = subject_config[:image]
      expected_entities[:volumes][:items][0][:properties][:imagePassword] = subject_config[:image_password]

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
