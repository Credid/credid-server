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

* **Command**: `AUTH : username password`
* **Description**: Connect a user identified with its username and its secret password.
* **Arguments**:
  * `username`
  * `password`
* **Return value**:
  * `success`: if the username+password matche
  * `failure`: if the username+password doesn't match
* **Example**: `AUTH : root toor`

##### Check a resource

* **Command**: `USER HAS_ACCESS TO : perm resource`
* **Description**: Check if the connected user has access to a resource (path + permission)
* **Arguments**:
  * `perm`: usually "write"
  * `resource`: the path of the resource. It can also be a command, etc.
* **Return value**:
  * `success`
  * `failure`: if not connected / not permitted
* **Example**: `USER HAS ACCESS TO : write /wiki/some/page`

##### Add a new permission to a group

* **Command**: `GROUP ADD : group perm resource`
* **Description**: Add a new permission (perm+path) to a group. Create the group if needed.
* **Arguments**:
  * `group`: the concerned group
  * `perm`: usually "write"
  * `resource`: the path of the resource. It can also be a command, etc.
* **Return value**:
  * `success`
  * `failure`: if not connected / not permitted
* **Example**: `GROUP ADD : root * write`

##### Remove a group

* **Command**: `GROUP REMOVE : group`
* **Description**: Delete a group with all associated permissions. Does not remove the group from the users.
* **Arguments**:
  * `group`: the concerned group
* **Return value**:
  * `success`
  * `failure`: if not connected / not permitted
* **Example**: `GROUP REMOVE : some_group`

##### List the existing groups

* **Command**: `GROUP LIST`
* **Description**: List all the existing groups that have not been removed.
* **Arguments**: none
* **Return value**:
  * `success ["group", ...]`
  * `failure`: if not connected / not permitted
* **Example**: `USER LIST`

##### List the permissions associated to a group

* **Command**: `GROUP LIST PERMS : group`
* **Description**: List the permissions (perm+path) associated to a group
* **Arguments**:
  * `group`: the concerned group
* **Return value**:
  * `success {"path" => "perm"}`
  * `failure`: if not connected / not permitted
* **Example**: `GROUP LIST PERMS : root`

##### Get the permission of a group on a resource

*note: it might be removed in the next versions.*

* **Command**: `GROUP GET PERM : group resource`
* **Description**: Get the permission (perm) of a group on a given resource, without matching.
* **Arguments**:
  * `group`: the concerned group
  * `resource`: resource to look at
* **Return value**:
  * `success "perm"`
  * `failure`: if not connected / not permitted
* **Example**: `GROUP GET PERM : root *`

##### List the existing users

* **Command**: `USER LIST`
* **Description**: List all the existing users.
* **Arguments**: none
* **Return value**:
  * `success ["username", ...]`
  * `failure`: if not connected / not permitted
* **Example**: `USER LIST`

##### Create a new user

* **Command**: `USER ADD : username password`
* **Description**: Create a new user.
* **Arguments**:
  * `username`: identifier of the user
  * `password`: secret of the user
* **Return value**:
  * `success`
  * `failure`: if not connected / not permitted / the username already exists
* **Example**: `USER ADD : root toor`

##### Remove a user

* **Command**: `USER REMOVE : username`
* **Description**: Remove an existing user.
* **Arguments**:
  * `username`: identifier of the user
* **Return value**:
  * `success`
  * `failure`: if not connected / not permitted
* **Example**: `USER REMOVE : user_to_delete`

##### Add a group to a user

* **Command**: `USER ADD GROUP : username group`
* **Description**: The groups belongs to the given group and has its same permissions.
* **Arguments**:
  * `username`: identifier of the user
  * `group`: group to add
* **Return value**:
  * `success`
  * `failure`: if not connected / not permitted / the username already exists
* **Example**: `USER ADD GROUP : root group_of_the_administrators`

##### Remove a group to a user

* **Command**: `USER REMOVE GROUP : username group`
* **Description**: The user does not belongs to the group anymore.
* **Arguments**:
  * `username`: identifier of the user
  * `goup`: group to remove
* **Return value**:
  * `success`
  * `failure`: if not connected / not permitted
* **Example**: `USER REMOVE GROUP : user grpi_to_delete`

##### List the groups of a user

* **Command**: `USER LIST GROUP : username`
* **Description**: Get the list of the groups of a user
* **Arguments**:
  * `username`: identifier of the user
* **Return value**:
  * `success ["group", ...]`
  * `failure`: if not connected / not permitted
* **Example**: `USER LIST GROUP : user`

##### Change the password of a user

* **Command**: `USER CHANGE PASSWORD : username password`
* **Description**: Modifies the secret password of a user.
* **Arguments**:
  * `username`: identifier of the user
  * `password`: new password to use instead of the old one
* **Return value**:
  * `success`
  * `failure`: if not connected / not permitted
* **Example**: `USER CHANGE PASSWORD : root toor_should_not_be_used_in_prod`

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
