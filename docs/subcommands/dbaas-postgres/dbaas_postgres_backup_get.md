# DbaasPostgresBackupGet

Retrieve a PostgreSQL cluster backup by using its ID. This value can be found when you GET a list of PostgreSQL cluster backups.

```text
knife ionoscloud dbaas postgres cluster get (options)
```

## Available options:

### Required options:

* backup\_id

```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    backup_id: --backup-id BACKUP_ID, -B BACKUP_ID
        iD of the cluster backup (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud dbaas postgres cluster get --url URL --extra-config EXTRA_CONFIG_FILE_PATH --backup-id BACKUP_ID --username USERNAME --password PASSWORD --token PASSWORD
```
