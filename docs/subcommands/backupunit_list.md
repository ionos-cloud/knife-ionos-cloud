# BackupunitList

Retrieve a list of all the backup units the supplied credentials have access to.

```text
knife ionoscloud backupunit list
```

## Available options:

### Required options:

* ionoscloud\_username
* ionoscloud\_password

```text
    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

```
## Example

```text
knife ionoscloud backupunit list--username USERNAME --password PASSWORD --extra-config EXTRA_CONFIG_FILE_PATH
```
