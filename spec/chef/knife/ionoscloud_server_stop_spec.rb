require 'spec_helper'
require 'ionoscloud_server_stop'

Chef::Knife::IonoscloudServerStop.load_deps

describe Chef::Knife::IonoscloudServerStop do
  before :each do
    subject { Chef::Knife::IonoscloudServerStop.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should output success when the ID is valid' do
      test_server_start_stop_restart_404(subject, 'stop')
    end

    it 'should output failure when the user ID is not valid' do
      test_server_start_stop_restart_404(subject, 'stop')
    end

    it 'should not make any call if any required option is missing' do
      check_required_options(subject)
    end
  end
end
