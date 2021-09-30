require 'spec_helper'
require 'ionoscloud_share_get'

Chef::Knife::IonoscloudShareGet.load_deps

describe Chef::Knife::IonoscloudShareGet do
  before :each do
    subject { Chef::Knife::IonoscloudShareGet.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call UserManagementApi.um_groups_shares_find_by_resource_id' do
      share = group_share_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        group_id: 'group_id',
        resource_id: share.id,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      check_share_print(subject, share)

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/um/groups/#{subject_config[:group_id]}/shares/#{subject_config[:resource_id]}",
            operation: :'UserManagementApi.um_groups_shares_find_by_resource_id',
            return_type: 'GroupShare',
            result: share,
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
