# BackupunitCreate

Create a new backup unit.

```text
knife ionoscloud backupunit create (options)
```

## Available options:

### Required options:

* name
* password
* email
* ionoscloud\_username
* ionoscloud\_password

```text
    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    name: --name NAME, -n NAME
        alphanumeric name you want assigned to the backup unit (required)

    password: --password PASSWORD, -p PASSWORD
        alphanumeric password you want assigned to the backup unit (required)

    email: --email EMAIL
        the e-mail address you want assigned to the backup unit. (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    ionoscloud_url: --url URL
        the Ionoscloud API URL

```
## Example

```text
knife ionoscloud backupunit create --extra-config EXTRA_CONFIG_FILE_PATH --name NAME --password PASSWORD --email EMAIL --username USERNAME --password PASSWORD --url URL
```
