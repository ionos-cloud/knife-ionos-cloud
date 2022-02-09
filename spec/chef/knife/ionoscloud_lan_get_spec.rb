require 'spec_helper'
require 'ionoscloud_lan_get'

Chef::Knife::IonoscloudLanGet.load_deps

describe Chef::Knife::IonoscloudLanGet do
  before :each do
    subject { Chef::Knife::IonoscloudLanGet.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call LANsApi.datacenters_lans_find_by_id' do
      lan = lan_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        lan_id: lan.id,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("ID: #{lan.id}")
      expect(subject).to receive(:puts).with("Name: #{lan.properties.name}")
      expect(subject).to receive(:puts).with("Public: #{lan.properties.public.to_s}")
      expect(subject).to receive(:puts).with("PCC: #{lan.properties.pcc}")
      expect(subject).to receive(:puts).with("IP Failover: #{[]}")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/lans/#{subject_config[:lan_id]}",
            operation: :'LANsApi.datacenters_lans_find_by_id',
            return_type: 'Lan',
            result: lan,
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
