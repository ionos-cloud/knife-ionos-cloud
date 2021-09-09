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

    email: --email EMAIL
        an e-mail address for the user. (required)

    password: --password PASSWORD, -p PASSWORD
        a password for the user. (required)

    administrator: --admin ADMIN, -a ADMIN
        assigns the user have administrative rights.

    force_sec_auth: --force-sec-auth
        indicates if secure (two-factor) authentication should be forced for the user.

    sec_auth_active: --sec-auth
        indicates if secure authentication is active for the user or not.

    active: --active
        indicates if the user is active.

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

```
## Example

```text
knife ionoscloud user create --firstname FIRSTNAME --lastname LASTNAME --email EMAIL --password PASSWORD --admin ADMIN --force-sec-auth --sec-auth --active --username USERNAME --password PASSWORD --extra-config EXTRA_CONFIG_FILE_PATH
```
