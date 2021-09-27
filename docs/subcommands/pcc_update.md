# PccUpdate

Updates information about a Ionoscloud Private Cross Connect. In order to add LANs to the Private Cross Connect one shouldupdate the LAN and change the pcc property using the ```text\knife ionscloud lan update\n``` command.

```text
knife ionoscloud pcc update (options)
```

## Available options:

### Required options:

* pcc\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    pcc_id: --pcc-id PRIVATE_CROSS_CONNECT_ID, -P PRIVATE_CROSS_CONNECT_ID
        iD of the Private Cross Connect (required)

    name: --name NAME, -n NAME
        name of the data center

    description: --description DESCRIPTION
        description of the data center

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

```
## Example

```text
knife ionoscloud pcc update --pcc-id PRIVATE_CROSS_CONNECT_ID --name NAME --description DESCRIPTION --username USERNAME --password PASSWORD --extra-config EXTRA_CONFIG_FILE_PATH
```
