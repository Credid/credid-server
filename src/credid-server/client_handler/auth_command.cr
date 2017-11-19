class Credid::Server::ClientHandler
  module CredidCommand
    extend self

    def auth(context, options, params)
      name, password = params.split(' ', 2) rescue raise "Not enough parameters (need 2)"
      context.user = context.context.users.auth? name, password
      context.user ? context.send_success : context.send_failure
    end

    def auth_token(context, options, params)
      name, token = params.split(' ', 2) rescue raise "Not enough parameters (need 2)"
      context.user = context.context.users.auth_token? name, token
      context.user ? context.send_success : context.send_failure
    end

    def gen_token(context, options, params)
      user = context.user.as(Acl::User)
      user.generate_new_token!
      context.send_success user.token
    end
  end
end
