require 'spec_helper'
require 'ionoscloud_server_list'

Chef::Knife::IonoscloudServerList.load_deps

describe Chef::Knife::IonoscloudServerList do
  before :each do
    subject { Chef::Knife::IonoscloudServerList.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call ServersApi.datacenters_servers_get' do
      servers = servers_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      server_list = [
        subject.ui.color('ID', :bold),
        subject.ui.color('Name', :bold),
        subject.ui.color('Type', :bold),
        subject.ui.color('Template', :bold),
        subject.ui.color('Cores', :bold),
        subject.ui.color('CPU Family', :bold),
        subject.ui.color('RAM', :bold),
        subject.ui.color('VM State', :bold),
        subject.ui.color('Boot Volume', :bold),
        subject.ui.color('Boot CDROM', :bold),
      ]

      servers.items.each do |server|
        server_list << server.id
        server_list << server.properties.name
        server_list << server.properties.type
        server_list << server.properties.template_uuid
        server_list << server.properties.cores.to_s
        server_list << server.properties.cpu_family
        server_list << server.properties.ram.to_s
        server_list << server.properties.vm_state
        server_list << (server.properties.boot_volume.nil? ? '' : server.properties.boot_volume.id)
        server_list << (server.properties.boot_cdrom.nil? ? '' : server.properties.boot_cdrom.id)
      end

      expect(subject.ui).to receive(:list).with(server_list, :uneven_columns_across, 10)

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers",
            operation: :'ServersApi.datacenters_servers_get',
            return_type: 'Servers',
            result: servers,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should call ServersApi.datacenters_servers_get with upgradeNeeded option when it is received' do
      servers = servers_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        upgrade_needed: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      server_list = [
        subject.ui.color('ID', :bold),
        subject.ui.color('Name', :bold),
        subject.ui.color('Type', :bold),
        subject.ui.color('Template', :bold),
        subject.ui.color('Cores', :bold),
        subject.ui.color('CPU Family', :bold),
        subject.ui.color('RAM', :bold),
        subject.ui.color('VM State', :bold),
        subject.ui.color('Boot Volume', :bold),
        subject.ui.color('Boot CDROM', :bold),
      ]

      servers.items.each do |server|
        server_list << server.id
        server_list << server.properties.name
        server_list << server.properties.type
        server_list << server.properties.template_uuid
        server_list << server.properties.cores.to_s
        server_list << server.properties.cpu_family
        server_list << server.properties.ram.to_s
        server_list << server.properties.vm_state
        server_list << (server.properties.boot_volume.nil? ? '' : server.properties.boot_volume.id)
        server_list << (server.properties.boot_cdrom.nil? ? '' : server.properties.boot_cdrom.id)
      end

      expect(subject.ui).to receive(:list).with(server_list, :uneven_columns_across, 10)

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers",
            options: { upgrade_needed: true },
            operation: :'ServersApi.datacenters_servers_get',
            return_type: 'Servers',
            result: servers,
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
