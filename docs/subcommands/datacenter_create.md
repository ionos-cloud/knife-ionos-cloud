# DatacenterCreate

Unless you are planning to manage an existing Ionoscloud environment, the first step will typically involve choosing the location for a new virtual data centerA list of locations can be obtained with location command.

	knife ionoscloud location list

Make a note of the desired location ID and now the data center can be created.


```text
knife ionoscloud datacenter create (options)
```

## Available options:

### Required options:

* location
* ionoscloud_username
* ionoscloud_password

```text
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

```
## Example

```text
knife ionoscloud datacenter create --name NAME --description DESCRIPTION --location LOCATION --username USERNAME --password PASSWORD
```
