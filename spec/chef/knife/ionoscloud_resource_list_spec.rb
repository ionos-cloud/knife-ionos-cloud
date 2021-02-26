require 'spec_helper'
require 'ionoscloud_resource_list'

Chef::Knife::IonoscloudResourceList.load_deps

describe Chef::Knife::IonoscloudResourceList do
  subject { Chef::Knife::IonoscloudResourceList.new }

  describe '#run' do
    it 'should call UserManagementApi.um_resources_find_by_type_and_id when resource_type and resource_id is set' do
      resources = resources_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        resource_type: 'resource_type',
        resource_id: 'resource_id',
      }
 
      subject_config.each { |key, value| subject.config[key] = value }

      resource_list = user_list = [
        subject.ui.color('ID', :bold),
        subject.ui.color('Type', :bold),
        subject.ui.color('Name', :bold),
        resources.items.first.id,
        resources.items.first.type,
        resources.items.first.properties.name,
      ]

      allow(subject).to receive(:puts)
      allow(subject).to receive(:print)
      allow(subject.ui).to receive(:list)

      expect(subject.ui).to receive(:list).with(user_list, :uneven_columns_across, 3)

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/um/resources/#{subject_config[:resource_type]}/#{subject_config[:resource_id]}",
            operation: :'UserManagementApi.um_resources_find_by_type_and_id',
            return_type: 'Resource',
            result: resources,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should call UserManagementApi.um_resources_find_by_type when only resource_type is set' do
      resources = resources_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        resource_type: 'resource_type',
      }
 
      subject_config.each { |key, value| subject.config[key] = value }

      resource_list = user_list = [
        subject.ui.color('ID', :bold),
        subject.ui.color('Type', :bold),
        subject.ui.color('Name', :bold),
        resources.items.first.id,
        resources.items.first.type,
        resources.items.first.properties.name,
      ]

      allow(subject).to receive(:puts)
      allow(subject).to receive(:print)
      allow(subject.ui).to receive(:list)

      expect(subject.ui).to receive(:list).with(user_list, :uneven_columns_across, 3)

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/um/resources/#{subject_config[:resource_type]}",
            operation: :'UserManagementApi.um_resources_find_by_type',
            return_type: 'Resources',
            result: resources,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should call UserManagementApi.um_resources_get when neither resource_type not resource_id are set' do
      resources = resources_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
      }
 
      subject_config.each { |key, value| subject.config[key] = value }

      resource_list = user_list = [
        subject.ui.color('ID', :bold),
        subject.ui.color('Type', :bold),
        subject.ui.color('Name', :bold),
        resources.items.first.id,
        resources.items.first.type,
        resources.items.first.properties.name,
      ]

      allow(subject).to receive(:puts)
      allow(subject).to receive(:print)
      allow(subject.ui).to receive(:list)

      expect(subject.ui).to receive(:list).with(user_list, :uneven_columns_across, 3)

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/um/resources",
            operation: :'UserManagementApi.um_resources_get',
            return_type: 'Resources',
            result: resources,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should call UserManagementApi.um_resources_get when only resource_id is set and warn the user' do
      resources = resources_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        resource_id: 'resource_id'
      }
 
      subject_config.each { |key, value| subject.config[key] = value }

      resource_list = user_list = [
        subject.ui.color('ID', :bold),
        subject.ui.color('Type', :bold),
        subject.ui.color('Name', :bold),
        resources.items.first.id,
        resources.items.first.type,
        resources.items.first.properties.name,
      ]

      allow(subject).to receive(:puts)
      allow(subject).to receive(:print)
      allow(subject.ui).to receive(:list)

      expect(subject.ui).to receive(:list).with(user_list, :uneven_columns_across, 3)
      expect(subject.ui).to receive(:warn).with('Ignoring resource_id because no resource_type was specified.')

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/um/resources",
            operation: :'UserManagementApi.um_resources_get',
            return_type: 'Resources',
            result: resources,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not make any call if any required option is missing' do
      required_options = subject.instance_variable_get(:@required_options)
      allow(subject).to receive(:puts)
      allow(subject).to receive(:print)

      arrays_without_one_element(required_options).each {
        |test_case|

        test_case[:array].each { |value| subject.config[value] = 'test' }

        expect(subject).to receive(:puts).with("Missing required parameters #{test_case[:removed]}")
        expect(subject.api_client).not_to receive(:call_api)
  
        expect { subject.run }.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(1)
        end

        required_options.each { |value| subject.config[value] = nil }
      }
    end
  end
end
