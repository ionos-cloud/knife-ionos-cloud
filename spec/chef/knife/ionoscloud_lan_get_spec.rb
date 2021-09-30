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
    it 'should call LanApi.datacenters_lans_find_by_id' do
      lan = lan_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        lan_id: lan.id,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      check_lan_print(subject, lan)

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/lans/#{subject_config[:lan_id]}",
            operation: :'LanApi.datacenters_lans_find_by_id',
            return_type: 'Lan',
            result: lan,
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
