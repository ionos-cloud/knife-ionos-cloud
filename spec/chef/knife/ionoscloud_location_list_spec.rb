require 'spec_helper'
require 'ionoscloud_location_list'

Chef::Knife::IonoscloudLocationList.load_deps

describe Chef::Knife::IonoscloudLocationList do
  describe '#run' do
    it 'should output the column headers' do
      {
        ionoscloud_username: ENV['IONOS_USERNAME'],
        ionoscloud_password: ENV['IONOS_PASSWORD'],
      }.each do |key, value|
        subject.config[key] = value
      end
      allow(subject).to receive(:puts)

      expect(subject).to receive(:puts).with(/ID\s+Name/)
      subject.run
    end
  end
end
