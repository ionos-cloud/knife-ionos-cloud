require 'spec_helper'
require 'ionoscloud_contract_list'

Chef::Knife::IonoscloudContractList.load_deps

describe Chef::Knife::IonoscloudContractList do
  before :each do
    subject { Chef::Knife::IonoscloudContractList.new }

    allow(subject).to receive(:puts)
    allow(subject).to receive(:print)
  end

  describe '#run' do
    it 'should call ContractApi.contracts_get' do
      contract = contract_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("Contract Type: #{contract.type}")
      expect(subject).to receive(:puts).with("Contract Owner: #{contract.properties.owner}")
      expect(subject).to receive(:puts).with("Contract Number: #{contract.properties.contract_number}")
      expect(subject).to receive(:puts).with("Registration Domain: #{contract.properties.reg_domain}")
      expect(subject).to receive(:puts).with("Status: #{contract.properties.status}")
      expect(subject).to receive(:puts).with("Cores per contract: #{contract.properties.resource_limits.cores_per_contract}")
      expect(subject).to receive(:puts).with("Cores per server: #{contract.properties.resource_limits.cores_per_server}")
      expect(subject).to receive(:puts).with("Cores provisioned: #{contract.properties.resource_limits.cores_provisioned}")
      expect(subject).to receive(:puts).with("HDD limit per contract: #{contract.properties.resource_limits.hdd_limit_per_contract}")
      expect(subject).to receive(:puts).with("HDD limit per volume: #{contract.properties.resource_limits.hdd_limit_per_volume}")
      expect(subject).to receive(:puts).with("HDD volume provisioned: #{contract.properties.resource_limits.hdd_volume_provisioned}")
      expect(subject).to receive(:puts).with("RAM per contract: #{contract.properties.resource_limits.ram_per_contract}")
      expect(subject).to receive(:puts).with("RAM per server: #{contract.properties.resource_limits.ram_per_server}")
      expect(subject).to receive(:puts).with("RAM provisioned: #{contract.properties.resource_limits.ram_provisioned}")
      expect(subject).to receive(:puts).with("Reservable IPs: #{contract.properties.resource_limits.reservable_ips}")
      expect(subject).to receive(:puts).with("Reservable IPs in use: #{contract.properties.resource_limits.reserved_ips_in_use}")
      expect(subject).to receive(:puts).with("Reservable IPs on contract: #{contract.properties.resource_limits.reserved_ips_on_contract}")
      expect(subject).to receive(:puts).with("SSD limit per contract: #{contract.properties.resource_limits.ssd_limit_per_contract}")
      expect(subject).to receive(:puts).with("SSD limit per volume: #{contract.properties.resource_limits.ssd_limit_per_volume}")
      expect(subject).to receive(:puts).with("SSD volume provisioned: #{contract.properties.resource_limits.ssd_volume_provisioned}")
      expect(subject).to receive(:puts).with("K8s Cluster Limit Total: #{contract.properties.resource_limits.k8s_cluster_limit_total}")
      expect(subject).to receive(:puts).with("K8s Clusters provisioned: #{contract.properties.resource_limits.k8s_clusters_provisioned}")

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: '/contracts',
            operation: :'ContractApi.contracts_get',
            return_type: 'Contract',
            result: contract,
          },
        ],
      )

      expect { subject.run }.not_to raise_error(Exception)
    end

    it 'should not make any call if any required option is missing' do
      check_required_options(subject)
    end
  end
end
