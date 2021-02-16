## Create Data Center

Unless you are planning to manage an existing Ionoscloud environment, the first step will typically involve choosing the location for a new virtual data center. A list of locations can be obtained with location command.

    knife ionoscloud location list

Make a note of the desired location ID and now the data center can be created.

    knife ionoscloud datacenter create --name "Production" --description "Production webserver environment" --location "us/las"

### Allowed options

    -l, --location LOCATION (required)
        Location of the data center
    -n, --name NAME
        Name of the data center
    -D, --description DESCRIPTION
        Description of the data center
 