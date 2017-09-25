class Auth::Server::ClientHandler
  module GroupCommand
    extend self

    # Create the group if it does not exists.
    # And add the permission [path] = perm if specified
    def add(context, options, params)
      tmp = params.split ' ', 3
      group, perm, path = tmp[0], tmp[1]?, tmp[2]?
      context.groups.transaction! do |groups|
        group_e = groups.add(group)[group]
        group_e[path] = Acl::PERM_STR[perm] if perm && path
        context.send_success
      end
    end

    # Remove a path from the group
    private def remove_path(context, group, path)
      context.groups.transaction! do |groups|
        group_e = groups[group]?
        group_e.delete path unless group_e.nil?
        # TODO : Clear the group if needed
        # groups.delete group if group_e.empty?
        # context.users.transaction! { |users| users.each{|u| u.groups.delete group } }
        context.send_success
      end
    end

    # Remove the whole group
    private def remove_group(context, group)
      context.groups.transaction! do |groups|
        groups.delete group
        context.send_success
      end
    end

    # Remove a group or ONE permission of the group
    def remove(context, options, params)
      splitted_params = params.split ' ', 2
      group = splitted_params[0]
      path = splitted_params[1]?
      path ? remove_path(context, group, path) : remove_group(context, group)
    end

    # List the existing groups
    def list(context, options, params)
      groups = context.groups.groups.keys
      context.send_success Query.apply_options_on(groups, options).inspect
    end

    # List the permissions of a group
    def list_perms(context, options, params)
      perms = context.groups[params]?
      if perms
        perms = perms.permissions.map { |k, v| {k.to_s, v.to_s} }.to_h
        context.send_success Query.apply_options_on(perms, options).inspect
      else
        context.send_success "{}"
      end
    end

    # Get the permission of a group on a resource
    def get_perm(context, options, params)
      group, path = params.split ' ', 2
      group = context.groups[group]?
      context.send_success((group ? group[path].to_s : "None").inspect)
    end
  end
end
