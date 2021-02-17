# VolumeDetach



    knife ionoscloud volume detach VOLUME_ID [VOLUME_ID] (options)


## Available options:

```
    ionoscloud_username: --username USERNAME, -u USERNAME
        Your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        Your Ionoscloud password

    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        The ID of the data center

    server_id: --server-id SERVER_ID, -S SERVER_ID
        The ID of the server

```

## Example

    knife ionoscloud volume detach VOLUME_ID --username USERNAME --password PASSWORD --datacenter-id DATACENTER_ID --server-id SERVER_ID
