class Auth::Server::ClientHandler
  module AuthCommand
    extend self

    def auth(context, params)
      name, password = params.split(' ', 2) rescue raise "Not enough parameters (need 2)"
      context.user = context.context.users.auth? name, password
      context.user ? context.send_success : context.send_failure
    end
  end
end
