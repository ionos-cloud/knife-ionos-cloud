require 'spec_helper'
require 'ionoscloud_server_get'

Chef::Knife::IonoscloudServerGet.load_deps

describe Chef::Knife::IonoscloudServerGet do
  before :each do
    subject { Chef::Knife::IonoscloudServerGet.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call ServersApi.datacenters_servers_find_by_id' do
      server = server_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        server_id: server.id,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{server.id}")
      expect(subject).to receive(:puts).with("Name: #{server.properties.name}")
      expect(subject).to receive(:puts).with("Type: #{server.properties.type}")
      expect(subject).to receive(:puts).with("Template: #{server.properties.template_uuid}")
      expect(subject).to receive(:puts).with("Cores: #{server.properties.cores}")
      expect(subject).to receive(:puts).with("CPU Family: #{server.properties.cpu_family}")
      expect(subject).to receive(:puts).with("Ram: #{server.properties.ram}")
      expect(subject).to receive(:puts).with("Availability Zone: #{server.properties.availability_zone}")
      expect(subject).to receive(:puts).with("VM State: #{server.properties.vm_state}")
      expect(subject).to receive(:puts).with("Boot Volume: #{server.properties.boot_volume.id}")
      expect(subject).to receive(:puts).with("Boot CDROM: #{server.properties.boot_cdrom.id}")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{subject_config[:server_id]}",
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
