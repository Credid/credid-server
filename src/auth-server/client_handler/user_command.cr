class Auth::Server::ClientHandler
  module UserCommand
    extend self

    def has_access_to(context, params)
      perm, path = params.split ' ', 2
      acl = context.groups.permitted? context.connected_user, path, Acl::PERM_STR[perm]
      acl ? context.send_success : context.send_failure
    end

    def add(context, params)
      name, password = params.split ' ', 2
      begin
        context.users.register! name, password
        context.send_success
      rescue err
        context.send_failure "cannot register this user #{err}"
      end
    end

    def remove(context, params)
      context.users.transaction! do |users|
        users.delete params
      end
      context.send_success
    end

    def add_group(context, params)
      user, group = params.split ' ', 2
      context.users.transaction! do |users|
        user = users[user.to_s]?
        user.groups << group if user
      end
      context.send_success
    end

    def remove_group(context, params)
      user, group = params.split ' ', 2
      context.users.transaction! do |users|
        user = users[user.to_s]?
        user.groups.delete group if user
      end
      context.send_success
    end

    def list_groups(context, params)
      user = context.users[params]?
      context.send_success(user ? user.groups.inspect : "[]")
    end

    def change_password(context, params)
      user, password = params.split ' ', 2
      context.users.transaction! do |users|
        user = users[user.to_s]?
        if user
          user.password = password
          user.encrypt!
        end
      end
      context.send_success
    end
  end
end
