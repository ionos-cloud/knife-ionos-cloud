# BackupunitCreate

Create a new backup unit.

    knife ionoscloud backupunit create (options)


## Available options:
---

### Required options:
* name
* password
* email
* ionoscloud_username
* ionoscloud_password

```
    name: --name NAME, -n NAME
        alphanumeric name you want assigned to the backup unit (required)

    password: --password PASSWORD, -p PASSWORD
        alphanumeric password you want assigned to the backup unit (required)

    email: --email EMAIL, -e EMAIL
        the e-mail address you want assigned to the backup unit. (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

```

## Example

    knife ionoscloud backupunit create --name NAME --password PASSWORD --email EMAIL --username USERNAME --password PASSWORD
