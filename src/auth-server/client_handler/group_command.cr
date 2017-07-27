class Auth::Server::ClientHandler
  module GroupCommand
    extend self

    def add(context, params)
      group, perm, path = params.split ' ', 3
      context.groups[group][path] = Acl::PERM_STR[perm]
      context.send_success
    end

    private def remove_path(context, group, path)
      group = context.groups[group]?
      group.delete path if group
      context.send_success
    end

    private def remove_group(context, group)
      context.groups.delete group
      context.send_success
    end

    def remove(context, params)
      splitted_params = params.split ' ', 2
      group = splitted_params[0]
      path = splitted_params[1]?
      path ? remove_path(context, group, path) : remove_group(context, group)
    end
  end
end
