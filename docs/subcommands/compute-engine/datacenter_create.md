# DatacenterCreate

Unless you are planning to manage an existing Ionoscloud environment, the first step will typically involve choosing the location for a new virtual data centerA list of locations can be obtained with location command.

	```text
knife ionoscloud location list
```

Make a note of the desired location ID and now the data center can be created.


```text
knife ionoscloud datacenter create (options)
```

## Available options:

### Required options:

* location
* ionoscloud\_username
* ionoscloud\_password

```text
    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    name: --name NAME, -n NAME
        name of the data center

    description: --description DESCRIPTION, -D DESCRIPTION
        description of the data center

    location: --location LOCATION, -l LOCATION
        location of the data center (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    ionoscloud_url: --url URL
        the Ionoscloud API URL

```
## Example

```text
knife ionoscloud datacenter create --extra-config EXTRA_CONFIG_FILE_PATH --name NAME --description DESCRIPTION --location LOCATION --username USERNAME --password PASSWORD --url URL
```
