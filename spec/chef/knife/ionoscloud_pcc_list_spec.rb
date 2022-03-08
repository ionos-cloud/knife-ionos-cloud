require 'spec_helper'
require 'ionoscloud_pcc_list'

Chef::Knife::IonoscloudPccList.load_deps

describe Chef::Knife::IonoscloudPccList do
  before :each do
    subject { Chef::Knife::IonoscloudPccList.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call PrivateCrossConnectsApi.pccs_get' do
      pccs = pccs_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      pcc_list = [
        subject.ui.color('ID', :bold),
        subject.ui.color('Name', :bold),
        subject.ui.color('Description', :bold),
        pccs.items.first.id,
        pccs.items.first.properties.name,
        pccs.items.first.properties.description || '',
      ]

      expect(subject.ui).to receive(:list).with(pcc_list, :uneven_columns_across, 3)

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: '/pccs',
            operation: :'PrivateCrossConnectsApi.pccs_get',
            return_type: 'PrivateCrossConnects',
            result: pccs,
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
