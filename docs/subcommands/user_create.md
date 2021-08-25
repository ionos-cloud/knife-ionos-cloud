# UserCreate

Creates a new user under a particular contract. **Please Note**: The password set here cannot be updated through the API currently. It is recommended that a new user log into the DCD and change their password.

```text
knife ionoscloud user create (options)
```

## Available options:

### Required options:

* firstname
* lastname
* email
* password
* ionoscloud\_username
* ionoscloud\_password

```text
    firstname: --firstname FIRSTNAME, -f FIRSTNAME
        firstname of the user. (required)

    lastname: --lastname LASTNAME, -l LASTNAME
        lastname of the user. (required)

    email: --email EMAIL, -e EMAIL
        an e-mail address for the user. (required)

    password: --password PASSWORD, -p PASSWORD
        a password for the user. (required)

    administrator: --admin ADMIN, -a ADMIN
        assigns the user have administrative rights.

    force_sec_auth: --sec-auth
        indicates if secure (two-factor) authentication should be forced for the user.

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    extra_config_file: --extra-config EXTRA_CONFIG_FILE, -e EXTRA_CONFIG_FILE
        additional config file name

```
## Example

```text
knife ionoscloud user create --firstname FIRSTNAME --lastname LASTNAME --email EMAIL --password PASSWORD --admin ADMIN --sec-auth --username USERNAME --password PASSWORD --extra-config EXTRA_CONFIG_FILE
```
