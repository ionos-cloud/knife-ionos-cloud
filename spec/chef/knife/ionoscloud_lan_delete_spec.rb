require 'spec_helper'
require 'ionoscloud_lan_delete'

Chef::Knife::IonoscloudLanDelete.load_deps

describe Chef::Knife::IonoscloudLanDelete do
  before :each do
    subject { Chef::Knife::IonoscloudLanDelete.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call LANsApi.datacenters_lans_delete when the ID is valid' do
      lan = lan_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
        yes: true,
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [lan.id]

      expect(subject).to receive(:puts).with("ID: #{lan.id}")
      expect(subject).to receive(:puts).with("Name: #{lan.properties.name}")
      expect(subject).to receive(:puts).with("Public: #{lan.properties.public.to_s}")
      expect(subject).to receive(:puts).with("PCC: #{lan.properties.pcc}")
      expect(subject).to receive(:puts).with("IP Failover: #{[]}")
      expect(subject.ui).to receive(:warn).with("Deleted Lan #{lan.id}. Request ID: ")

      expect(subject.api_client).not_to receive(:wait_for)
      expect(subject).to receive(:get_request_id).once
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/lans/#{lan.id}",
            operation: :'LANsApi.datacenters_lans_find_by_id',
            return_type: 'Lan',
            result: lan,
          },
          {
            method: 'DELETE',
            path: "/datacenters/#{subject_config[:datacenter_id]}/lans/#{lan.id}",
            operation: :'LANsApi.datacenters_lans_delete',
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not call LANsApi.datacenters_lans_delete when the user ID is not valid' do
      lan_id = 'invalid_id'
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
        datacenter_id: 'datacenter_id',
      }

      subject_config.each { |key, value| subject.config[key] = value }
      subject.name_args = [lan_id]

      expect(subject.ui).to receive(:error).with("Lan ID #{lan_id} not found. Skipping.")

      expect(subject.api_client).not_to receive(:wait_for)
      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: "/datacenters/#{subject_config[:datacenter_id]}/lans/#{lan_id}",
            operation: :'LANsApi.datacenters_lans_find_by_id',
            return_type: 'Lan',
            exception: Ionoscloud::ApiError.new(code: 404),
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
