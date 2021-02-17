# DatacenterCreate

Unless you are planning to manage an existing Ionoscloud environment, the first step will typically involve choosing the location for a new virtual data centerA list of locations can be obtained with location command.

	knife ionoscloud location list

Make a note of the desired location ID and now the data center can be created.


    knife ionoscloud datacenter create (options)


## Available options:

```
* ionoscloud_username: --username USERNAME, -u USERNAME   Your Ionoscloud username
* ionoscloud_password: --password PASSWORD, -p PASSWORD   Your Ionoscloud password
* name: --name NAME, -n NAME   Name of the data center
* description: --description DESCRIPTION, -D DESCRIPTION   Description of the data center
* location: --location LOCATION, -l LOCATION   Location of the data center
```

## Example

    knife ionoscloud datacenter create --username USERNAME --password PASSWORD --name NAME --description DESCRIPTION --location LOCATION
