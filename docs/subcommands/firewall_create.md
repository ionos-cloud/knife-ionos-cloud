# FirewallCreate

Creates a new firewall rule on an existing NIC.

```text
knife ionoscloud firewall create (options)
```

## Available options:

### Required options:

* datacenter\_id
* server\_id
* nic\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        iD of the data center (required)

    server_id: --server-id SERVER_ID, -S SERVER_ID
        iD of the server (required)

    nic_id: --nic-id NIC_ID, -N NIC_ID
        iD of the NIC (required)

    name: --name NAME, -n NAME
        name of the Firewall Rule

    protocol: --protocol PROTOCOL, -P PROTOCOL
        the protocol of the firewall rule (TCP, UDP, ICMP, ANY)

    source_mac: --source-mac MAC, -m MAC
        only traffic originating from the respective MAC address is allowed

    source_ip: --source-ip IP, -I IP
        only traffic originating from the respective IPv4 address is allowed; null allows all source IPs

    target_ip: --target-ip IP
        in case the target NIC has multiple IP addresses, only traffic directed to the respective IP address of the NIC is allowed; null value allows all target IPs

    port_range_start: --port-range-start PORT, -p PORT
        defines the start range of the allowed port(s)

    port_range_end: --port-range-end PORT, -t PORT
        defines the end range of the allowed port(s)

    icmp_type: --icmp-type INT
        defines the allowed type (from 0 to 254) if the protocol ICMP is chosen; null allows all types

    icmp_code: --icmp-code INT
        defines the allowed code (from 0 to 254) if the protocol ICMP is chosen; null allows all codes

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    ionoscloud_url: --url URL
        the Ionoscloud API URL

```
## Example

```text
knife ionoscloud firewall create --extra-config EXTRA_CONFIG_FILE_PATH --datacenter-id DATACENTER_ID --server-id SERVER_ID --nic-id NIC_ID --name NAME --protocol PROTOCOL --source-mac MAC --source-ip IP --target-ip IP --port-range-start PORT --port-range-end PORT --icmp-type INT --icmp-code INT --username USERNAME --password PASSWORD --url URL
```
