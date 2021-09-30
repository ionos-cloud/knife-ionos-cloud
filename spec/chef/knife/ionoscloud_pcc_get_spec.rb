require 'spec_helper'
require 'ionoscloud_pcc_get'

Chef::Knife::IonoscloudPccGet.load_deps

describe Chef::Knife::IonoscloudPccGet do
  before :each do
    subject { Chef::Knife::IonoscloudPccGet.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call PrivateCrossConnectApi.pccs_find_by_id' do
      pcc = pcc_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        pcc_id: pcc.id,
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      check_pcc_print(subject, pcc)

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/pccs/#{pcc.id}",
            operation: :'PrivateCrossConnectApi.pccs_find_by_id',
            return_type: 'PrivateCrossConnect',
            result: pcc,
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
