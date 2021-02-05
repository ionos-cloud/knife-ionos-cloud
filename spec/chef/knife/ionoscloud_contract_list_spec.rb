require 'spec_helper'
require 'ionoscloud_contract_list'

Chef::Knife::IonoscloudContractList.load_deps

describe Chef::Knife::IonoscloudContractList do
  subject { Chef::Knife::IonoscloudContractList.new }

  describe '#run' do
    it 'should output the column headers and some values' do
      {
        ionoscloud_username: ENV['IONOS_USERNAME'],
        ionoscloud_password: ENV['IONOS_PASSWORD'],
      }.each do |key, value|
        subject.config[key] = value
      end
      allow(subject).to receive(:puts)

      expect(subject).to receive(:puts).with(match('Contract Type: contract'))
      expect(subject).to receive(:puts).with(match('Contract Number: \d+'))
      expect(subject).to receive(:puts).with(match('Status: BILLABLE'))
      expect(subject).to receive(:puts).with(match('Cores per server: \d+'))
      expect(subject).to receive(:puts).with(match('Cores per contract: \d+'))
      expect(subject).to receive(:puts).with(match('Cores provisioned: \d+'))
      expect(subject).to receive(:puts).with(match('RAM per server: \d+'))
      expect(subject).to receive(:puts).with(match('RAM per contract: \d+'))
      expect(subject).to receive(:puts).with(match('RAM provisioned: \d+'))
      expect(subject).to receive(:puts).with(match('HDD limit per volume: \d+'))
      expect(subject).to receive(:puts).with(match('HDD limit per contract: \d+'))
      expect(subject).to receive(:puts).with(match('HDD volume provisioned: \d+'))
      expect(subject).to receive(:puts).with(match('SSD limit per volume: \d+'))
      expect(subject).to receive(:puts).with(match('SSD limit per contract: \d+'))
      expect(subject).to receive(:puts).with(match('SSD volume provisioned: \d+'))
      expect(subject).to receive(:puts).with(match('Reservable IPs: \d+'))
      expect(subject).to receive(:puts).with(match('Reservable IPs on contract: \d+'))
      expect(subject).to receive(:puts).with(match('Reservable IPs in use: \d+'))

      subject.run
    end
  end
end
