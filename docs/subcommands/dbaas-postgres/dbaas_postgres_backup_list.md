# DbaasPostgresBackupList

If cluster_id is provided, retrieves a list of all backups of the given PostgreSQL cluster, otherwise retrieves a list of all PostgreSQL cluster backups.

```text
knife ionoscloud dbaas postgres backup list (options)
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
knife ionoscloud dbaas postgres backup list --url URL --extra-config EXTRA_CONFIG_FILE_PATH --cluster-id CLUSTER_ID --username USERNAME --password PASSWORD --token PASSWORD
```
