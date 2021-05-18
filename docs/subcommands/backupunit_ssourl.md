# BackupunitSsourl

The ProfitBricks backup system features a web-based GUI. Once you have created a backup unit, you can access the GUI with a Single Sign On (SSO) URL that can be retrieved from the Cloud API using this request.

    knife ionoscloud backupunit ssourl (options)


## Available options:
---

### Required options:
* backupunit_id
* ionoscloud_username
* ionoscloud_password

```
    backupunit_id: --backupunit-id BACKUPUNIT_ID, -B BACKUPUNIT_ID
        the ID of the Backup unit. (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)
<<<<<<< HEAD
=======

```
>>>>>>> master

```
## Example

<<<<<<< HEAD
```text
knife ionoscloud backupunit ssourl --backupunit-id BACKUPUNIT_ID --username USERNAME --password PASSWORD
```
=======
    knife ionoscloud backupunit ssourl --backupunit-id BACKUPUNIT_ID --username USERNAME --password PASSWORD
>>>>>>> master
