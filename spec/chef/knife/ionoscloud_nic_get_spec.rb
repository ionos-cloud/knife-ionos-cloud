require 'spec_helper'
require 'ionoscloud_nic_get'

Chef::Knife::IonoscloudNicGet.load_deps

describe Chef::Knife::IonoscloudNicGet do
  before :each do
    subject { Chef::Knife::IonoscloudNicGet.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call NicApi.datacenters_servers_nics_find_by_id' do
      nic = nic_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        server_id: 'server_id',
        nic_id: nic.id,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      check_nic_print(subject, nic)

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/servers/#{subject_config[:server_id]}/nics/#{subject_config[:nic_id]}",
            operation: :'NicApi.datacenters_servers_nics_find_by_id',
            return_type: 'Nic',
            result: nic,
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
