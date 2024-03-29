# DbaasPostgresVersionList

If cluster_id is provided, retrieves a list of all PostgreSQL versions available for a cluster including the current version, otherwise retrieves a list of all available PostgreSQL versions.

```text
knife ionoscloud dbaas postgres version list
```

## Available options:

### Required options:


```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    cluster_id: --cluster-id CLUSTER_ID, -C CLUSTER_ID
        iD of the cluster

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud dbaas postgres version list--url URL --extra-config EXTRA_CONFIG_FILE_PATH --cluster-id CLUSTER_ID --username USERNAME --password PASSWORD --token PASSWORD
```
