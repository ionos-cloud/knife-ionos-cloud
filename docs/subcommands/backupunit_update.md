# BackupunitUpdate

Retrieves information about a backup unit.

```text
knife ionoscloud backupunit update (options)
```

## Available options:

### Required options:

* backupunit\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    backupunit_id: --backupunit-id BACKUPUNIT_ID, -B BACKUPUNIT_ID
        the ID of the Backup unit. (required)

    password: --password PASSWORD, -p PASSWORD
        alphanumeric password you want assigned to the backup unit

    email: --email EMAIL
        the e-mail address you want assigned to the backup unit.

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

```
## Example

```text
knife ionoscloud backupunit update --backupunit-id BACKUPUNIT_ID --password PASSWORD --email EMAIL --username USERNAME --password PASSWORD --extra-config EXTRA_CONFIG_FILE_PATH
```
