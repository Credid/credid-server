# auth-server

Authentication and permission management server.

## Installation

    make

## Usage

TODO: Write usage instructions here

### Protocol

The first user create is "root" with the password "toor". It has the group "root" which has "write \*" access.
The default group should have the access "USER changepassword \$ \*"


Definitions:

* Group: \[a-zA-Z0-9][a-zA-Z0-9_-]+
* User: \[a-zA-Z0-9][a-zA-Z0-9_-]+
* Perm: \[a-zA-Z0-9][a-zA-Z0-9_-]+
* Path: .+
* Password: .+

In the paths:

* \*: character is replaced with .+ (unless escaped with \\)
* \$: character is replaced with \[a-zA-Z0-9][a-zA-Z0-9_-]+ (unless escaped with \\)
* \a: is replaced with the username of the current authenticated user (the \a is never registrated, it is replaced by the real name)
* \u: is replaced with the user that executes the request

Errors:

* The only error case happens if the connected user have not the rights to do something
* If an user add another user, it will replace the old entry if it already exists (keep the connection alive if replace itself)

#### Authenticate on the server

    AUTH : user password
    # => success / failure

##### Check a resource

    # Check if the user has access to a resource for the connected user
    USER HAS_ACCESS TO : perm path
    # => success / failure
    USER HAS ACCESS TO : write /wiki/some/page

##### Manage groups

    # Add a new entry to a group (and create the group if it does not exists).
    GROUP ADD : group perm path
    # => success / failure
    GROUP ADD : admin write *

    # Remove a group permission.
    GROUP REMOVE : group path
    # => success / failure
    GROUP REMOVE : group guest *

    # Remove a group.
    GROUP REMOVE : group
    # => success / failure
    GROUP REMOVE : old system

    # List the permissions of a group.
    GROUP LIST group
    # => success\n{"perm" => "path", ...} / failure
    GROUP LIST:  admin

    # List the groups.
    GROUP LIST
    # => success\n["group", ...] / failure
    GROUP LIST

    # Get the permissions of a group a a fiven path
    GROUP GET PERM : group path
    # => success\n"perm" / failure
    GROUP GET PERM : "guest"

##### Manage the users

    # Add an user
    USER ADD : user password
    # => success / failure
    USER ADD : root toor

    # Add a group to an user. Create inexisting groups.
    USER ADD GROUP : user group
    # => success / failure
    USER ADD GROUP : root admin

    # List the gorups of an user
    USER LIST GROUP : user
    # => success\n["group", ...] / failure
    USER LIST GROUP : \a

    # Remove a group from an user. If their is no such group or if the user does not belong to it, it does nothing.
    USER REMOVE GROUP : user group
    # => success / failure
    USER REMOVE GROUP me guest

    # Change the password of an user
    USER CHANGEPASSWORD : user newpassword
    # => success / failure
    USER CHANGEPASSWORD : root bettertoorpassword


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
