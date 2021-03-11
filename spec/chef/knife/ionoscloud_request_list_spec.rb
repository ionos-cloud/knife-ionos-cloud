require 'spec_helper'
require 'ionoscloud_request_list'

Chef::Knife::IonoscloudRequestList.load_deps

describe Chef::Knife::IonoscloudRequestList do
  before :each do
    subject { Chef::Knife::IonoscloudRequestList.new }

    @requests = requests_mock
    @request_list = request_list = [
      subject.ui.color('ID', :bold),
      subject.ui.color('Status', :bold),
      subject.ui.color('Method', :bold),
      subject.ui.color('Targets', :bold),
    ]

    @requests.items.each do |request|
      @request_list << request.id
      @request_list << request.metadata.request_status.metadata.status
      @request_list << request.properties.method
      @request_list << request.metadata.request_status.metadata.targets.map { |target| [target.target.id, target.target.type] }.to_s

    end

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call RequestApi.resources_get with default options when nothing is set' do
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject.ui).to receive(:list).with(@request_list, :uneven_columns_across, 4)

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: '/requests',
            operation: :'RequestApi.requests_get',
            options: { depth: 2, limit: 20, offset: 0 },
            return_type: 'Requests',
            result: @requests,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should call RequestApi.resources_get with set options if present' do
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        offset: 3,
        limit: 6,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject.ui).to receive(:list).with(@request_list, :uneven_columns_across, 4)

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: '/requests',
            operation: :'RequestApi.requests_get',
            options: { depth: 2, limit: subject_config[:limit], offset: subject_config[:offset] },
            return_type: 'Requests',
            result: @requests,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should call RequestApi.resources_get with default limit if it is not an Integers' do
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        limit: 'invalid',
        offset: 3,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject.ui).to receive(:list).with(@request_list, :uneven_columns_across, 4)
      expect(subject.ui).to receive(:warn).with('limit should be an Integer!')

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: '/requests',
            operation: :'RequestApi.requests_get',
            options: { depth: 2, limit: 20, offset: subject_config[:offset] },
            return_type: 'Requests',
            result: @requests,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should call RequestApi.resources_get with default offset if it is not an Integers' do
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        offset: 'invalid',
        limit: 12,
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject.ui).to receive(:list).with(@request_list, :uneven_columns_across, 4)
      expect(subject.ui).to receive(:warn).with('offset should be an Integer!')

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: '/requests',
            operation: :'RequestApi.requests_get',
            options: { depth: 2, limit: subject_config[:limit], offset: 0 },
            return_type: 'Requests',
            result: @requests,
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