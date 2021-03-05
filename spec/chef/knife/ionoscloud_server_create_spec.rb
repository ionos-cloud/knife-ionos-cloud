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

      expect(subject).to receive(:puts).with("ID: #{server.id}")
      expect(subject).to receive(:puts).with("Name: #{server.properties.name}")
      expect(subject).to receive(:puts).with("Cores: #{server.properties.cores}")
      expect(subject).to receive(:puts).with("CPU Family: #{server.properties.cpu_family}")
      expect(subject).to receive(:puts).with("Ram: #{server.properties.ram}")
      expect(subject).to receive(:puts).with("Availability Zone: #{server.properties.availability_zone}")
      expect(subject).to receive(:puts).with("Boot Volume: #{server.properties.boot_volume.id}")
      expect(subject).to receive(:puts).with("Boot CDROM: #{server.properties.boot_cdrom.id}")

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
