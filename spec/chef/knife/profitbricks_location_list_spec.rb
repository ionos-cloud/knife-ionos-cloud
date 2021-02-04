require 'spec_helper'
require 'profitbricks_location_list'

Chef::Knife::ProfitbricksLocationList.load_deps

describe Chef::Knife::ProfitbricksLocationList do
  describe '#run' do
    it 'should output the column headers' do
      {
        profitbricks_username: ENV['IONOS_USERNAME'],
        profitbricks_password: ENV['IONOS_PASSWORD'],
      }.each do |key, value|
        subject.config[key] = value
      end
      allow(subject).to receive(:puts)

      expect(subject).to receive(:puts).with(/ID\s+Name/)
      subject.run
    end
  end
end
