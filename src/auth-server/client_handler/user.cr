class Auth::Server::ClientHandler
  module User
    extend self

    def handle(context, cmd2)
      p2 = cmd2.split ' ', 2
      case p2[0]
      when "LIST_GROUP"
        group = p2[1]?
        if group.nil? || group == "\\a"
          context.send_success context.user.as(Acl::User).groups.inspect
        else
          context.send_failure
        end
      else
        context.send_failure "not implemented"
      end
    end
  end
end
