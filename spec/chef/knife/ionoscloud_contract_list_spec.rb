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
    it 'should call ContractResourcesApi.contracts_get' do
      contracts = contracts_mock
      subject_config = {
        ionoscloud_username: 'email',
        ionoscloud_password: 'password',
      }

      subject_config.each { |key, value| subject.config[key] = value }

      expect(subject).to receive(:puts).with("Contract Type: #{contracts.items.first.type}")
      expect(subject).to receive(:puts).with("Contract Owner: #{contracts.items.first.properties.owner}")
      expect(subject).to receive(:puts).with("Contract Number: #{contracts.items.first.properties.contract_number}")
      expect(subject).to receive(:puts).with("Registration Domain: #{contracts.items.first.properties.reg_domain}")
      expect(subject).to receive(:puts).with("Status: #{contracts.items.first.properties.status}")
      expect(subject).to receive(:puts).with("Cores per contract: #{contracts.items.first.properties.resource_limits.cores_per_contract}")
      expect(subject).to receive(:puts).with("Cores per server: #{contracts.items.first.properties.resource_limits.cores_per_server}")
      expect(subject).to receive(:puts).with("Cores provisioned: #{contracts.items.first.properties.resource_limits.cores_provisioned}")
      expect(subject).to receive(:puts).with("HDD limit per contract: #{contracts.items.first.properties.resource_limits.hdd_limit_per_contract}")
      expect(subject).to receive(:puts).with("HDD limit per volume: #{contracts.items.first.properties.resource_limits.hdd_limit_per_volume}")
      expect(subject).to receive(:puts).with("HDD volume provisioned: #{contracts.items.first.properties.resource_limits.hdd_volume_provisioned}")
      expect(subject).to receive(:puts).with("RAM per contract: #{contracts.items.first.properties.resource_limits.ram_per_contract}")
      expect(subject).to receive(:puts).with("RAM per server: #{contracts.items.first.properties.resource_limits.ram_per_server}")
      expect(subject).to receive(:puts).with("RAM provisioned: #{contracts.items.first.properties.resource_limits.ram_provisioned}")
      expect(subject).to receive(:puts).with("Reservable IPs: #{contracts.items.first.properties.resource_limits.reservable_ips}")
      expect(subject).to receive(:puts).with("Reservable IPs in use: #{contracts.items.first.properties.resource_limits.reserved_ips_in_use}")
      expect(subject).to receive(:puts).with("Reservable IPs on contract: #{contracts.items.first.properties.resource_limits.reserved_ips_on_contract}")
      expect(subject).to receive(:puts).with("SSD limit per contract: #{contracts.items.first.properties.resource_limits.ssd_limit_per_contract}")
      expect(subject).to receive(:puts).with("SSD limit per volume: #{contracts.items.first.properties.resource_limits.ssd_limit_per_volume}")
      expect(subject).to receive(:puts).with("SSD volume provisioned: #{contracts.items.first.properties.resource_limits.ssd_volume_provisioned}")
      expect(subject).to receive(:puts).with("DAS volume provisioned: #{contracts.items.first.properties.resource_limits.das_volume_provisioned}")
      expect(subject).to receive(:puts).with("K8s Cluster Limit Total: #{contracts.items.first.properties.resource_limits.k8s_cluster_limit_total}")
      expect(subject).to receive(:puts).with("K8s Clusters provisioned: #{contracts.items.first.properties.resource_limits.k8s_clusters_provisioned}")
      expect(subject).to receive(:puts).with("NLB total limit: #{contracts.items.first.properties.resource_limits.nlb_limit_total}")
      expect(subject).to receive(:puts).with("NLBs provisioned: #{contracts.items.first.properties.resource_limits.nlb_provisioned}")
      expect(subject).to receive(:puts).with("NAT gateway total limit: #{contracts.items.first.properties.resource_limits.nat_gateway_limit_total}")
      expect(subject).to receive(:puts).with("NAT gateways provisioned: #{contracts.items.first.properties.resource_limits.nat_gateway_provisioned}")

      mock_call_api(
        subject,
        [
          {
            method: 'GET',
            path: '/contracts',
            operation: :'ContractResourcesApi.contracts_get',
            return_type: 'Contracts',
            result: contracts,
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
