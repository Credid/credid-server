class Auth::Server::ClientHandler
  module Auth
    extend self

    def handle(context, cmd2)
      name, password = cmd2.split(' ', 2) rescue raise "Not enough parameters (need 2)"
      context.user = context.context.users.auth?(name, password)
      context.user ? context.send_success : context.send_failure
    end
  end
end
