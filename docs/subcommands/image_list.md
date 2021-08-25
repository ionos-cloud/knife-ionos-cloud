# ImageList

A list of disk and ISO images are available from Ionoscloud for immediate use. Make sure the image you use is in the same location as the virtual data center.

```text
knife ionoscloud image list
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

    extra_config_file: --extra-config EXTRA_CONFIG_FILE, -e EXTRA_CONFIG_FILE
        additional config file name

```
## Example

```text
knife ionoscloud image list--username USERNAME --password PASSWORD --extra-config EXTRA_CONFIG_FILE
```
