# VolumeGet

Retrieves the attributes of a given Volume.

```text
knife ionoscloud volume get (options)
```

## Available options:

### Required options:

* datacenter\_id
* volume\_id

```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        iD of the data center (required)

    volume_id: --volume VOLUME_ID
        iD of the volume. (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud volume get --url URL --extra-config EXTRA_CONFIG_FILE_PATH --datacenter-id DATACENTER_ID --volume VOLUME_ID --username USERNAME --password PASSWORD --token PASSWORD
```
