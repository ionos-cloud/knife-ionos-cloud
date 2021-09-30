require 'spec_helper'
require 'ionoscloud_lan_create'

Chef::Knife::IonoscloudLanCreate.load_deps

describe Chef::Knife::IonoscloudLanCreate do
  before :each do
    subject { Chef::Knife::IonoscloudLanCreate.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call LanApi.datacenters_lans_post with the expected arguments and output based on what it receives' do
      lan = lan_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        name: lan.properties.name,
        public: lan.properties.public,
        pcc: lan.properties.pcc,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      check_lan_print(subject, lan)

      expected_body = lan.properties.to_hash
      expected_body.delete(:ipFailover)

      mock_wait_for(subject)
      mock_call_api(
        subject,
        [
          {
            method: 'POST',
            path: "/datacenters/#{subject_config[:datacenter_id]}/lans",
            operation: :'LanApi.datacenters_lans_post',
            return_type: 'LanPost',
            body: { properties: expected_body },
            result: lan,
          },
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/lans/#{lan.id}",
            operation: :'LanApi.datacenters_lans_find_by_id',
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
