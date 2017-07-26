class Auth::Server::ClientHandler
  module Group
    extend self

    def handle(context, cmd2)
      return context.send_failure "not connected" if context.user.nil?
      context.send_failure "not implemented"
    end
  end
end
