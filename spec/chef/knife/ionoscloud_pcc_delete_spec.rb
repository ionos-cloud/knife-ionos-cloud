require 'spec_helper'
require 'ionoscloud_pcc_delete'

Chef::Knife::IonoscloudPccDelete.load_deps

describe Chef::Knife::IonoscloudPccDelete do
  before :each do
    subject { Chef::Knife::IonoscloudPccDelete.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call PrivateCrossConnectApi.pccs_delete when the ID is valid' do
      pcc = pcc_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [pcc.id]

      check_pcc_print(subject, pcc)
      expect(subject.ui).to receive(:warn).with("Deleted PCC #{pcc.id}. Request ID: ")

      expect(subject.api_client).not_to receive(:wait_for)
      expect(subject).to receive(:get_request_id).once
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
          {
            method: 'DELETE',
            path: "/pccs/#{pcc.id}",
            operation: :'PrivateCrossConnectApi.pccs_delete',
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call PrivateCrossConnectApi.pccs_delete when the ID is not valid' do
      pcc_id = 'invalid_id'
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [pcc_id]

      expect(subject.ui).to receive(:error).with("PCC ID #{pcc_id} not found. Skipping.")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/pccs/#{pcc_id}",
            operation: :'PrivateCrossConnectApi.pccs_find_by_id',
            return_type: 'PrivateCrossConnect',
            exception: Ionoscloud::ApiError.new(code: 404),
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
