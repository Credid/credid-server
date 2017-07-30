class Auth::Server::ClientHandler
  module GroupCommand
    extend self

    def add(context, params)
      group, perm, path = params.split ' ', 3
      context.groups.transaction! do |groups|
        group_e = groups[group]?
        group_e[path] = Acl::PERM_STR[perm] unless group_e.nil?
        context.send_success
      end
    end

    private def remove_path(context, group, path)
      context.groups.transaction! do |groups|
        group_e = groups[group]?
        group_e.delete path unless group_e.nil?
        context.send_success
      end
    end

    private def remove_group(context, group)
      context.groups.transaction! do |groups|
        groups.delete group
        context.send_success
      end
    end

    def remove(context, params)
      splitted_params = params.split ' ', 2
      group = splitted_params[0]
      path = splitted_params[1]?
      path ? remove_path(context, group, path) : remove_group(context, group)
    end

    def list(context, params)
      context.send_success context.groups.groups.keys.inspect
    end

    def list_perms(context, params)
      perms = context.groups[params]?
      if perms
        context.send_success perms.permissions.map { |k, v| {k.to_s, v.to_s} }.to_h.inspect
      else
        context.send_success "{}"
      end
    end

    def get_perm(context, params)
      group, path = params.split ' ', 2
      group = context.groups[group]?
      context.send_success((group ? group[path].to_s : "None").inspect)
    end
  end
end
