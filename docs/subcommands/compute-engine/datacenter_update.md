# DatacenterUpdate

Updates information about a Ionoscloud Datacenter.

```text
knife ionoscloud datacenter update (options)
```

## Available options:

### Required options:

* datacenter\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        iD of the data center (required)

    name: --name NAME, -n NAME
        name of the data center

    description: --description DESCRIPTION
        description of the data center

    sec_auth_protection: --sec-auth-protection SEC_AUTH_PROTECTION
        boolean value representing if the data center requires extra protection e.g. two factor protection

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    ionoscloud_url: --url URL
        the Ionoscloud API URL

```
## Example

```text
knife ionoscloud datacenter update --extra-config EXTRA_CONFIG_FILE_PATH --datacenter-id DATACENTER_ID --name NAME --description DESCRIPTION --sec-auth-protection SEC_AUTH_PROTECTION --username USERNAME --password PASSWORD --url URL
```
