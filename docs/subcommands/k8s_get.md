# K8sGet

Retrieves information about a K8s Cluster.

```text
knife ionoscloud k8s get (options)
```

## Available options:

### Required options:

* cluster\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    cluster_id: --cluster-id CLUSTER_ID, -C CLUSTER_ID
        iD of the Kubernetes cluster (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

```
## Example

```text
knife ionoscloud k8s get --cluster-id CLUSTER_ID --username USERNAME --password PASSWORD --extra-config EXTRA_CONFIG_FILE_PATH
```
