require 'spec_helper'
require 'ionoscloud_location_list'

Chef::Knife::IonoscloudLocationList.load_deps

describe Chef::Knife::IonoscloudLocationList do
  before :each do
    subject { Chef::Knife::IonoscloudLocationList.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call LocationApi.locations_get' do
      locations = locations_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      location_list = [
        subject.ui.color('ID', :bold),
        subject.ui.color('Name', :bold),
        locations.items.first.id,
        locations.items.first.properties.name,
      ]

      expect(subject.ui).to receive(:list).with(location_list, :uneven_columns_across, 2)

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: '/locations',
            operation: :'LocationApi.locations_get',
            return_type: 'Locations',
            result: locations,
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
