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
      check_required_options(subject)
    end
  end
end
