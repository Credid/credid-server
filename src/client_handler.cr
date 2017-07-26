require "./client_handler/*"

class Auth::Server::ClientHandler
  getter context : Handler
  getter client : OpenSSL::SSL::Socket::Server | TCPSocket
  property user : Acl::User?
  property authenticated : Bool

  def initialize(@context, @client)
    @user = nil
    @authenticated = false
  end

  def handle
    loop do
      cmd = @client.gets
      if cmd.nil?
        @client.close
        break
      else
        handle_command cmd
      end
    end
  end

  def send_success(msg : String? = nil)
    @client.puts msg ? "success #{msg}" : "success"
  end

  def send_failure(msg : String? = nil)
    @client.puts msg ? "failure #{msg}" : "failure"
  end

  private def handle_command(cmd)
    split1 = cmd.split(' ', 2)
    p1 = split1[0]
    cmd2 = split1[1]? || ""

    # Verifies the permissions unless it is AUTH
    if p1 != "AUTH"
      return send_failure "not connected" if user.nil?
      return send_failure "not permitted" unless context.groups.permitted? user.as(Acl::User), cmd, Acl::Perm::Write
    end

    # Execute the operation if permitted
    begin
      handler_module = ROOT_HANDLERS[p1]
      begin
        handler_module.handle(self, cmd2)
      rescue err
        send_failure("invalid command parameters #{err}")
      end
    rescue err
      send_failure("failure unknown command #{err}")
    end
  end

  ROOT_HANDLERS = {
    "AUTH" => ClientHandler::Auth,
    "GROUP" => ClientHandler::Group,
    "USER" => ClientHandler::User,
  }
end
