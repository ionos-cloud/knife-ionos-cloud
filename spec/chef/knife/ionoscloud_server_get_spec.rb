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
    it 'should call ServerApi.datacenters_servers_find_by_id' do
      server = server_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        server_id: server.id,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      check_server_print(subject, server)

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
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
      check_required_options(subject)
    end
  end
end
