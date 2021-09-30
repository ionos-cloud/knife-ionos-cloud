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
    it 'should call ServerApi.datacenters_servers_post with the expected arguments and output based on what it receives' do
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
        image_alias: 'debian:latest',
        image_password: 'K3tTj8G14a3EgKyNeeiY',

        lan: server.entities.nics.items.first.properties.lan,
        nic_name: server.entities.nics.items.first.properties.name,
        dhcp: server.entities.nics.items.first.properties.dhcp,
        ips: server.entities.nics.items.first.properties.ips.join(','),
        nat: server.entities.nics.items.first.properties.nat,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      check_server_print(subject, server)

      expected_properties = server.properties.to_hash
      expected_properties.delete(:bootCdrom)
      expected_properties.delete(:bootVolume)

      expected_entities = server.entities.to_hash
      expected_entities[:volumes][:items][0].delete(:id)
      expected_entities[:volumes][:items][0][:properties].delete(:image)
      expected_entities[:nics][:items][0].delete(:id)
      expected_entities[:nics][:items][0].delete(:entities)
      expected_entities[:nics][:items][0][:properties].delete(:mac)
      expected_entities[:nics][:items][0][:properties].delete(:firewallActive)

      expected_entities[:volumes][:items][0][:properties][:imageAlias] = subject_config[:image_alias]
      expected_entities[:volumes][:items][0][:properties][:imagePassword] = subject_config[:image_password]

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers",
            operation: :'ServerApi.datacenters_servers_post',
            return_type: 'Server',
            body: { properties: expected_properties, entities: expected_entities },
            result: server,
          },
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{server.id}",
            operation: :'ServerApi.datacenters_servers_find_by_id',
            return_type: 'Server',
            result: server,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not make any call if any required option is missing' do
      check_required_options(subject)
    end
  end
end
