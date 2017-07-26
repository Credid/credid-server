class Auth::Server::ClientHandler
  module UserCommand
    extend self

    def list_group(context, params)
      group = params
      if group.empty? || group == "\\a"
        context.send_success context.user.as(Acl::User).groups.inspect
      else
        context.send_failure
      end
    end

    def has_access_to(context, params)
      perm, path = params.split(' ', 2)
      acl = context.context.groups.permitted? context.connected_user, path, Acl::PERM_STR[perm]
      acl ? context.send_success : context.send_failure
    end
  end
end
