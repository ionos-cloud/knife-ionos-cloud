# FirewallCreate



    knife ionoscloud firewall create (options)


## Available options:

```
    ionoscloud_username: --username USERNAME, -u USERNAME
        Your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        Your Ionoscloud password

    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        ID of the data center

    server_id: --server-id SERVER_ID, -S SERVER_ID
        ID of the server

    nic_id: --nic-id NIC_ID, -N NIC_ID
        ID of the NIC

    name: --name NAME, -n NAME
        Name of the NIC

    protocol: --protocol PROTOCOL, -P PROTOCOL
        The protocol of the firewall rule (TCP, UDP, ICMP, ANY)

    sourcemac: --source-mac MAC, -m MAC
        Only traffic originating from the respective MAC address is allowed

    sourceip: --source-ip IP, -I IP
        Only traffic originating from the respective IPv4 address is allowed; null allows all source IPs

    targetip: --target-ip IP
        In case the target NIC has multiple IP addresses, only traffic directed to the respective IP address of the NIC is allowed; null value allows all target IPs

    portrangestart: --port-range-start PORT, -p PORT
        Defines the start range of the allowed port(s)

    portrangeend: --port-range-end PORT, -t PORT
        Defines the end range of the allowed port(s)

    icmptype: --icmp-type INT
        Defines the allowed type (from 0 to 254) if the protocol ICMP is chosen; null allows all types

    icmpcode: --icmp-code INT
        Defines the allowed code (from 0 to 254) if the protocol ICMP is chosen; null allows all codes

```

## Example

    knife ionoscloud firewall create --username USERNAME --password PASSWORD --datacenter-id DATACENTER_ID --server-id SERVER_ID --nic-id NIC_ID --name NAME --protocol PROTOCOL --source-mac MAC --source-ip IP --target-ip IP --port-range-start PORT --port-range-end PORT --icmp-type INT --icmp-code INT
