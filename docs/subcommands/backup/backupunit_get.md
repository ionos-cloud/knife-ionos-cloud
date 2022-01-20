# BackupunitGet

Retrieves information about a backup unit.

```text
knife ionoscloud backupunit get (options)
```

## Available options:

### Required options:

* backupunit\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    backupunit_id: --backupunit-id BACKUPUNIT_ID, -B BACKUPUNIT_ID
        the ID of the Backup unit. (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    ionoscloud_url: --url URL
        the Ionoscloud API URL

```
## Example

```text
knife ionoscloud backupunit get --extra-config EXTRA_CONFIG_FILE_PATH --backupunit-id BACKUPUNIT_ID --username USERNAME --password PASSWORD --url URL
```
