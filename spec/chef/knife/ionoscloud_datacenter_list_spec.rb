require 'spec_helper'
require 'ionoscloud_datacenter_list'

Chef::Knife::IonoscloudDatacenterList.load_deps

describe Chef::Knife::IonoscloudDatacenterList do
  subject { Chef::Knife::IonoscloudDatacenterList.new }

  before :each do
    @datacenter = create_test_datacenter()

    allow(subject).to receive(:puts)
  end

  after :each do
    Ionoscloud::DataCenterApi.new.datacenters_delete(@datacenter.id)
  end

  describe '#run' do
    it 'should output the column headers and the datacenter' do
      {
        ionoscloud_username: ENV['IONOS_USERNAME'],
        ionoscloud_password: ENV['IONOS_PASSWORD'],
      }.each do |key, value|
        subject.config[key] = value
      end

      expect(subject).to receive(:puts).with(
        %r{
          (^ID\s+Name\s+Description\s+Location\s+Version\s*$\n.*
          #{@datacenter.id}\s+#{@datacenter.properties.name.gsub(' ', '\s')}\s+
          #{@datacenter.properties.description.gsub(' ', '\s')}\s+
          #{@datacenter.properties.location}\s+1\s*$)
        }x
      )
      subject.run
    end
  end
end
