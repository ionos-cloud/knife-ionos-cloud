require 'spec_helper'
require 'profitbricks_image_list'

Chef::Knife::ProfitbricksImageList.load_deps

describe Chef::Knife::ProfitbricksImageList do
  subject { Chef::Knife::ProfitbricksImageList.new }

  describe '#run' do
    it 'should output the column headers' do
      {
        profitbricks_username: ENV['IONOS_USERNAME'],
        profitbricks_password: ENV['IONOS_PASSWORD'],
      }.each do |key, value|
        subject.config[key] = value
      end
      allow(subject).to receive(:puts)

      expect(subject).to receive(:puts).with(/^ID\s+Name\s+Description\s+Location\s+Size\s+Public\s*$/)
      subject.run
    end
  end
end
