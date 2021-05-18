# BackupunitDelete

A backup unit may be deleted using a DELETE request. Deleting a backup unit is a dangerous operation. A successful DELETE request will remove the backup plans inside a backup unit, ALL backups associated with the backup unit, the backup user and finally the backup unit itself.

```text
knife ionoscloud backupunit delete BACKUPUNIT_ID [BACKUPUNIT_ID]
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

```
## Example

```text
knife ionoscloud backupunit delete BACKUPUNIT_ID [BACKUPUNIT_ID]--username USERNAME --password PASSWORD
```
