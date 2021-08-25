# NetworkloadbalancerRuleAdd

Adds a Forwarding Rule to a Network Load Balancer under a data center.

```text
knife ionoscloud networkloadbalancer rule add (options)
```

## Available options:

### Required options:

* datacenter\_id
* network\_loadbalancer\_id
* name
* listener\_ip
* listener\_port
* ionoscloud\_username
* ionoscloud\_password

```text
    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        name of the data center (required)

    network_loadbalancer_id: --network-loadbalancer NETWORK_LOADBALANCER_ID, -L NETWORK_LOADBALANCER_ID
        iD of the Network Loadbalancer (required)

    name: --name NAME, -n NAME
        a name of that Network Load Balancer forwarding rule (required)

    algorithm: --algorithm ALGORITHM, -a ALGORITHM
        algorithm for the balancing

    protocol: --protocol PROTOCOL
        protocol of the balancing

    listener_ip: --ip LISTENER_IP, -i LISTENER_IP
        listening IP. (inbound) (required)

    listener_port: --port LISTENER_PORT, -p LISTENER_PORT
        listening port number. (inbound) (range: 1 to 65535) (required)

    client_timeout: --client-timeout CLIENT_TIMEOUT
        clientTimeout is expressed in milliseconds. This inactivity timeout applies when the client is expected to acknowledge or send data. If unset the default of 50 seconds will be used.

    check_timeout: --check-timeout CLIENT_TIMEOUT
        it specifies the time (in milliseconds) for a target VM in this pool to answer the check. If a target VM has CheckInterval set and CheckTimeout is set too, then the smaller value of the two is used after the TCP connection is established.

    connect_timeout: --connect-timeout CONNECT_TIMEOUT
        it specifies the maximum time (in milliseconds) to wait for a connection attempt to a target VM to succeed. If unset, the default of 5 seconds will be used.

    target_timeout: --terget-timeout TARGET_TIMEOUT
        targetTimeout specifies the maximum inactivity time (in milliseconds) on the target VM side. If unset, the default of 50 seconds will be used.

    retries: --retries RETRIES, -r RETRIES
        retries specifies the number of retries to perform on a target VM after a connection failure. If unset, the default value of 3 will be used. (valid range: [0, 65535])

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    extra_config_file: --extra-config EXTRA_CONFIG_FILE, -e EXTRA_CONFIG_FILE
        additional config file name

```
## Example

```text
knife ionoscloud networkloadbalancer rule add --datacenter-id DATACENTER_ID --network-loadbalancer NETWORK_LOADBALANCER_ID --name NAME --algorithm ALGORITHM --protocol PROTOCOL --ip LISTENER_IP --port LISTENER_PORT --client-timeout CLIENT_TIMEOUT --check-timeout CLIENT_TIMEOUT --connect-timeout CONNECT_TIMEOUT --terget-timeout TARGET_TIMEOUT --retries RETRIES --username USERNAME --password PASSWORD --extra-config EXTRA_CONFIG_FILE
```
