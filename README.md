# auth-server

Authentication and permission management server.

## Installation

    make

## Usage

    ./auth-server --ip 127.0.0.1 --port 8999

### Protocol

The first user create is "root" with the password "toor". It has the group "root" which has "write \*" access.
The default group should have the access "USER changepassword \$ \*"


Definitions:

* Group: `\[a-zA-Z0-9][a-zA-Z0-9_-]+`
* User: `\[a-zA-Z0-9][a-zA-Z0-9_-]+`
* Perm: `\[a-zA-Z0-9][a-zA-Z0-9_-]+`
* Path: `.+`
* Password: `.+`

In the paths:

* `*`: character is replaced with `.+` (unless escaped with `\`)
* `$`: character is replaced with `\[a-zA-Z0-9][a-zA-Z0-9_-]+` (unless escaped with `\`)
* `\a`: is replaced with the username of the current authenticated user (the `\a` is never registrated, it is replaced by the real name)
* `\u`: is replaced with the user that executes the request

Errors:

* The only error case happens if the connected user have not the rights to do something
* If a user add another user, it will replace the old entry if it already exists (keep the connection alive if replace itself)

#### Authenticate on the server

    AUTH : user password
    # => success / failure

##### Check a resource

    # Check if the user has access to a resource for the connected user
    USER HAS_ACCESS TO : perm path
    # => success / failure
    USER HAS ACCESS TO : write /wiki/some/page

##### Manage groups

    # Add a new entry to a group (create it if needed).
    GROUP ADD : group perm path
    # => success / failure
    GROUP ADD : admin write *

    # Remove a group permission.
    GROUP REMOVE : group path
    # => success / failure
    GROUP REMOVE : guest *

    # Remove a group.
    GROUP REMOVE : group
    # => success / failure
    GROUP REMOVE : somegroup

    # List the groups.
    GROUP LIST
    # => success ["group", ...] / failure
    GROUP LIST

    # List the permissions of a group.
    GROUP LIST PERMS : group
    # => success {"path" => "perm", ...} / failure
    GROUP LIST PERMS : admin

    # Get the permissions of a group a a fiven path
    GROUP GET PERM : group path
    # => success "perm" / failure
    GROUP GET PERM : "guest"

##### Manage the users

    # List the users
    USER LIST
    # => success ["group", ...] / failure
    USER LIST

    # Add a user.
    USER ADD : user password
    # => success / failure
    USER ADD : root toor

    # Remove a user
    USER REMOVE : user
    # => success / failure
    USER REMOVE : guest_user

    # Add a group to a user. Create inexisting groups.
    USER ADD GROUP : user group
    # => success / failure
    USER ADD GROUP : root admin

    # Remove a group from a user. Doe nothing if the group doesn't exists/...
    USER REMOVE GROUP : user group
    # => success / failure
    USER REMOVE GROUP me guest

    # List the groups of a user.
    USER LIST GROUPS : user
    # => success ["group", ...] / failure
    USER LIST GROUPS : \a

    # Change the password of a user.
    USER CHANGE PASSWORD : user newpassword
    # => success / failure
    USER CHANGE PASSWORD : root bettertoorpassword


## Development

TODO: Write development instructions here

## Contributing

1. Fork it ( https://github.com/AuthCr/auth-server/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [Nephos](https://github.com/Nephos) Arthur Poulet - creator, maintainer
