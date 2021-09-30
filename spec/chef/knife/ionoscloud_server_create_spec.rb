require 'spec_helper'
require 'ionoscloud_server_create'

Chef::Knife::IonoscloudServerCreate.load_deps

describe Chef::Knife::IonoscloudServerCreate do
  before :each do
    subject { Chef::Knife::IonoscloudServerCreate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call ServerApi.datacenters_servers_post with the expected arguments and output based on what it receives' do
      server = server_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        name: server.properties.name,
        cores: server.properties.cores,
        cpu_family: server.properties.cpu_family,
        ram: server.properties.ram,
        availability_zone: server.properties.availability_zone,
        boot_volume: server.properties.boot_volume.id,
        boot_cdrom: server.properties.boot_cdrom.id,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      check_server_print(subject, server)

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers",
            operation: :'ServerApi.datacenters_servers_post',
            return_type: 'Server',
            body: { properties: server.properties.to_hash },
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
