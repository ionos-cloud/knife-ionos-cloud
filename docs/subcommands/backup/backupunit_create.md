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

```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    name: --name NAME, -n NAME
        alphanumeric name you want assigned to the backup unit (required)

    password: --password PASSWORD, -p PASSWORD
        alphanumeric password you want assigned to the backup unit (required)

    email: --email EMAIL, -e EMAIL
        the e-mail address you want assigned to the backup unit. (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud backupunit create --url URL --extra-config EXTRA_CONFIG_FILE_PATH --name NAME --password PASSWORD --email EMAIL --username USERNAME --password PASSWORD --token PASSWORD
```
