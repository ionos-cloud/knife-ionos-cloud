# VolumeDetach

This will detach the volume from the server. Depending on the volume HotUnplug settings, this may result in the server being rebooted.

This will NOT delete the volume from your virtual data center. You will need to make a separate request to delete a volume.

```text
knife ionoscloud volume detach VOLUME_ID [VOLUME_ID] (options)
```

## Available options:

### Required options:

* datacenter\_id
* server\_id

```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        the ID of the data center (required)

    server_id: --server-id SERVER_ID, -S SERVER_ID
        the ID of the server (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud volume detach VOLUME_ID 
```
