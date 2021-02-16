require 'spec_helper'
require 'ionoscloud_image_list'

Chef::Knife::IonoscloudImageList.load_deps

describe Chef::Knife::IonoscloudImageList do
  subject { Chef::Knife::IonoscloudImageList.new }

  describe '#run' do
    it 'should output the column headers' do
      {
        ionoscloud_username: ENV['IONOS_USERNAME'],
        ionoscloud_password: ENV['IONOS_PASSWORD'],
      }.each do |key, value|
        subject.config[key] = value
      end
      allow(subject).to receive(:puts)

      expect(subject).to receive(:puts).with(/^ID\s+Name\s+Description\s+Location\s+Size\s+Public\s*$/)
      subject.run
    end
  end
end
