# FirewallCreate

Creates a new firewall rule on an existing NIC.

    knife ionoscloud firewall create (options)


## Available options:
---

### Required options:
* datacenter_id
* server_id
* nic_id

```
    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        iD of the data center (required)

    server_id: --server-id SERVER_ID, -S SERVER_ID
        iD of the server (required)

    nic_id: --nic-id NIC_ID, -N NIC_ID
        iD of the NIC (required)

    name: --name NAME, -n NAME
        name of the NIC

    protocol: --protocol PROTOCOL, -P PROTOCOL
        the protocol of the firewall rule (TCP, UDP, ICMP, ANY)

    sourcemac: --source-mac MAC, -m MAC
        only traffic originating from the respective MAC address is allowed

    sourceip: --source-ip IP, -I IP
        only traffic originating from the respective IPv4 address is allowed; null allows all source IPs

    targetip: --target-ip IP
        in case the target NIC has multiple IP addresses, only traffic directed to the respective IP address of the NIC is allowed; null value allows all target IPs

    portrangestart: --port-range-start PORT, -p PORT
        defines the start range of the allowed port(s)

    portrangeend: --port-range-end PORT, -t PORT
        defines the end range of the allowed port(s)

    icmptype: --icmp-type INT
        defines the allowed type (from 0 to 254) if the protocol ICMP is chosen; null allows all types

    icmpcode: --icmp-code INT
        defines the allowed code (from 0 to 254) if the protocol ICMP is chosen; null allows all codes

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

```

## Example

    knife ionoscloud firewall create --datacenter-id DATACENTER_ID --server-id SERVER_ID --nic-id NIC_ID --name NAME --protocol PROTOCOL --source-mac MAC --source-ip IP --target-ip IP --port-range-start PORT --port-range-end PORT --icmp-type INT --icmp-code INT --username USERNAME --password PASSWORD
