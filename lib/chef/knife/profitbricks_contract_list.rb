require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksContractList < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks contract list'

      def run
        $stdout.sync = true
        contract = Ionoscloud::ContractApi.new(api_client).contracts_get(default_opts)

        puts "#{ui.color('Contract Type', :cyan)}: #{contract.type}"
        puts "#{ui.color('Contract Number', :cyan)}: #{contract.properties.contract_number}"
        puts "#{ui.color('Status', :cyan)}: #{contract.properties.status}"
        puts "#{ui.color('Cores per server', :cyan)}: #{contract.properties.resource_limits.cores_per_server}"
        puts "#{ui.color('Cores per contract', :cyan)}: #{contract.properties.resource_limits.cores_per_contract}"
        puts "#{ui.color('Cores provisioned', :cyan)}: #{contract.properties.resource_limits.cores_provisioned}"
        puts "#{ui.color('RAM per server', :cyan)}: #{contract.properties.resource_limits.ram_per_server}"
        puts "#{ui.color('RAM per contract', :cyan)}: #{contract.properties.resource_limits.ram_per_contract}"
        puts "#{ui.color('RAM provisioned', :cyan)}: #{contract.properties.resource_limits.ram_provisioned}"
        puts "#{ui.color('HDD limit per volume', :cyan)}: #{contract.properties.resource_limits.hdd_limit_per_volume}"
        puts "#{ui.color('HDD limit per contract', :cyan)}: #{contract.properties.resource_limits.hdd_limit_per_contract}"
        puts "#{ui.color('HDD volume provisioned', :cyan)}: #{contract.properties.resource_limits.hdd_volume_provisioned}"
        puts "#{ui.color('SSD limit per volume', :cyan)}: #{contract.properties.resource_limits.ssd_limit_per_volume}"
        puts "#{ui.color('SSD limit per contract', :cyan)}: #{contract.properties.resource_limits.ssd_limit_per_contract}"
        puts "#{ui.color('SSD volume provisioned', :cyan)}: #{contract.properties.resource_limits.ssd_volume_provisioned}"
        puts "#{ui.color('Reservable IPs', :cyan)}: #{contract.properties.resource_limits.reservable_ips}"
        puts "#{ui.color('Reservable IPs on contract', :cyan)}: #{contract.properties.resource_limits.reserved_ips_on_contract}"
        puts "#{ui.color('Reservable IPs in use', :cyan)}: #{contract.properties.resource_limits.reserved_ips_in_use}"

      end
    end
  end
end
