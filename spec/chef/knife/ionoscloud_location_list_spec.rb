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
    it 'should call LocationsApi.locations_get' do
      locations = locations_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      location_list = [
        subject.ui.color('ID', :bold),
        subject.ui.color('Name', :bold),
        subject.ui.color('CPU Architectures', :bold),
        locations.items.first.id,
        locations.items.first.properties.name,
        locations.items.first.properties.cpu_architecture.map { |arch| arch.cpu_family },
      ]

      expect(subject.ui).to receive(:list).with(location_list, :uneven_columns_across, 3)

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: '/locations',
            operation: :'LocationsApi.locations_get',
            return_type: 'Locations',
            result: locations,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not make any call if any required option is missing' do
      required_options = subject.instance_variable_get(:@required_options)

      if required_options.length > 0
        arrays_without_one_element(required_options).each do |test_case|
          subject.config[:ionoscloud_token] = 'token'
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
end
