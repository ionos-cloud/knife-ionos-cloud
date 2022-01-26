# BackupunitSsourl

The ProfitBricks backup system features a web-based GUI. Once you have created a backup unit, you can access the GUI with a Single Sign On \(SSO\) URL that can be retrieved from the Cloud API using this request.

```text
knife ionoscloud backupunit ssourl (options)
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
knife ionoscloud backupunit ssourl --extra-config EXTRA_CONFIG_FILE_PATH --backupunit-id BACKUPUNIT_ID --username USERNAME --password PASSWORD --url URL
```
