# NodepoolList

Retrieve a list of all node pools contained in a selected Kubernetes cluster.

```text
knife ionoscloud nodepool list
```

## Available options:

### Required options:

* cluster\_id

```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    cluster_id: --cluster-id CLUSTER_ID, -C CLUSTER_ID
        the ID of the K8s Cluster (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud nodepool list--url URL --extra-config EXTRA_CONFIG_FILE_PATH --cluster-id CLUSTER_ID --username USERNAME --password PASSWORD --token PASSWORD
```
