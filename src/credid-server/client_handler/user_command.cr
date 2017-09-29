class Credid::Server::ClientHandler
  module UserCommand
    extend self

    # Check if a user has the access to the given resource.
    def has_access_to(context, options, params)
      user, perm, path = params.split ' ', 3
      user = context.users[user]?
      acl = context.groups.permitted? user, path, Acl::PERM_STR[perm] unless user.nil?
      acl ? context.send_success : context.send_failure
    end

    # List all the users.
    def list(context, options, params)
      users = context.users.list.keys
      context.send_success Query.apply_options_on(users, options).inspect
    end

    # Create a new user.
    def add(context, options, params)
      name, password = params.split ' ', 2
      begin
        context.users.register! name, password
        context.send_success
      rescue err
        context.send_failure "cannot register this user #{err}"
      end
    end

    # Remove an existing user.
    def remove(context, options, params)
      context.users.transaction! do |users|
        users.delete params
        context.context.disconnect_user(params)
      end
      context.send_success
    end

    # Add the user to a group.
    def add_group(context, options, params)
      user, group = params.split ' ', 2
      context.users.transaction! do |users|
        user = users[user.to_s]?
        user.groups << group if user && !user.groups.includes?(group)
      end
      context.send_success
    end

    # Remove a group from a user.
    def remove_group(context, options, params)
      user, group = params.split ' ', 2
      context.users.transaction! do |users|
        user = users[user.to_s]?
        user.groups.delete group if user
      end
      context.send_success
    end

    # List the groups of a user.
    def list_groups(context, options, params)
      user = context.users[params]?
      context.send_success(user ? Query.apply_options_on(user.groups, options).inspect : "[]")
    end

    # Change the password of a user.
    def change_password(context, options, params)
      user, password = params.split ' ', 2
      context.users.transaction! do |users|
        user = users[user.to_s]?
        if user
          user.password = password
          user.encrypt!
          context.context.disconnect_user(user.name)
        end
      end
      context.send_success
    end
  end
end
