# BackupunitUpdate

Retrieves information about a backup unit.

```text
knife ionoscloud backupunit update (options)
```

## Available options:

### Required options:

* backupunit\_id

```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    backupunit_id: --backupunit-id BACKUPUNIT_ID, -B BACKUPUNIT_ID
        the ID of the Backup unit. (required)

    password: --password PASSWORD, -p PASSWORD
        alphanumeric password you want assigned to the backup unit

    email: --email EMAIL
        the e-mail address you want assigned to the backup unit.

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud backupunit update --url URL --extra-config EXTRA_CONFIG_FILE_PATH --backupunit-id BACKUPUNIT_ID --password PASSWORD --email EMAIL --username USERNAME --password PASSWORD --token PASSWORD
```
