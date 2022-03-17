# UserUpdate

Updates information about a Ionoscloud User.

```text
knife ionoscloud user update (options)
```

## Available options:

### Required options:

* user\_id

```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    user_id: --user-id USER_ID, -U USER_ID
        iD of the User. (required)

    firstname: --firstname FIRSTNAME, -f FIRSTNAME
        firstname of the user.

    lastname: --lastname LASTNAME, -l LASTNAME
        lastname of the user.

    email: --email EMAIL
        an e-mail address for the user.

    administrator: --admin ADMIN, -a ADMIN
        assigns the user have administrative rights.

    force_sec_auth: --sec-auth FORCE_SEC_AUTH
        indicates if secure (two-factor) authentication should be forced for the user.

    sec_auth_active: --sec-auth SEC_AUTH_ACTIVE
        indicates if secure authentication is active for the user or not.

    active: --active ACTIVE
        indicates if the user is active.

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud user update --url URL --extra-config EXTRA_CONFIG_FILE_PATH --user-id USER_ID --firstname FIRSTNAME --lastname LASTNAME --email EMAIL --admin ADMIN --sec-auth FORCE_SEC_AUTH --sec-auth SEC_AUTH_ACTIVE --active ACTIVE --username USERNAME --password PASSWORD --token PASSWORD
```
