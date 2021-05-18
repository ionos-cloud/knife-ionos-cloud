# ServerStop

This will stop a server. The machine will be forcefully powered off, billing will cease, and the public IP, if one is allocated, will be deallocated.

    knife ionoscloud server stop SERVER_ID [SERVER_ID] (options)


## Available options:
---

### Required options:
* datacenter_id
* ionoscloud_username
* ionoscloud_password

```
    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        iD of the data center (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)
<<<<<<< HEAD
=======

```
>>>>>>> master

```
## Example

<<<<<<< HEAD
```text
knife ionoscloud server stop SERVER_ID 
```
=======
    knife ionoscloud server stop SERVER_ID 
>>>>>>> master
