# NodepoolLanAdd

Adds or updates a LAN within a Nodepool.

```text
knife ionoscloud nodepool lan add (options)
```

## Available options:

### Required options:

* cluster\_id
* nodepool\_id
* lan\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    cluster_id: --cluster-id CLUSTER_ID, -C CLUSTER_ID
        iD of the Kubernetes cluster (required)

    nodepool_id: --nodepool NODEPOOL_ID, -N NODEPOOL_ID
        the ID of the K8s Nodepool (required)

    lan_id: --lan LAN_ID, -L LAN_ID
        the ID of the LAN (required)

    no_dhcp: --nodhcp
        indicates if the Kubernetes Node Pool LAN will reserve an IP using DHCP

    routes: --routes NETWORK,GATEWAY_IP [NETWORK,GATEWAY_IP]
        an array of additional LANs attached to worker nodes

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    ionoscloud_url: --url URL
        the Ionoscloud API URL

```
## Example

```text
knife ionoscloud nodepool lan add --extra-config EXTRA_CONFIG_FILE_PATH --cluster-id CLUSTER_ID --nodepool NODEPOOL_ID --lan LAN_ID --nodhcp --routes NETWORK,GATEWAY_IP [NETWORK,GATEWAY_IP] --username USERNAME --password PASSWORD --url URL
```
