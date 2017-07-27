require "./client_handler/*"

class Auth::Server::ClientHandler
  alias CommandHandler = Proc(ClientHandler, String, Nil)
  macro add_handler(cmd, handler)
    ROOT_HANDLERS[{{cmd}}] = -> {{handler}}(ClientHandler, String)
  end
  ROOT_HANDLERS = Hash(String, CommandHandler).new

  add_handler "AUTH", ClientHandler::AuthCommand.auth
  add_handler "USER LIST GROUPS", ClientHandler::UserCommand.list_group
  add_handler "USER HAS ACCESS TO", ClientHandler::UserCommand.has_access_to
  add_handler "GROUP ADD", ClientHandler::GroupCommand.add
  add_handler "GROUP REMOVE", ClientHandler::GroupCommand.remove
  add_handler "GROUP LIST", ClientHandler::GroupCommand.list
  add_handler "GROUP LIST PERMS", ClientHandler::GroupCommand.list_perms
  add_handler "GROUP GET PERM", ClientHandler::GroupCommand.get_perm

  getter context : Handler
  getter client : OpenSSL::SSL::Socket::Server | TCPSocket
  property user : Acl::User?
  property authenticated : Bool
  delegate users, to: context
  delegate groups, to: context

  def initialize(@context, @client)
    @user = nil
    @authenticated = false
  end

  def connected_user : Acl::User
    raise "Not connected" if @user.nil?
    @user.as(Acl::User)
  end

  private def get_cmd
    cmd = client.gets
    client.close if cmd.nil?
    cmd
  end

  def handle
    loop do
      cmd = get_cmd
      break if cmd.nil?
      handle_command cmd
    end
  end

  def send(msg : String)
    client.print "#{msg}\n"
    client.flush
  end

  def send_success(msg : String? = nil)
    send msg ? "success #{msg}" : "success"
  end

  def send_failure(msg : String? = nil)
    send msg ? "failure #{msg}" : "failure"
  end

  private def handle_command(cmd)
    command_split = cmd.split ':', 2
    command_words = command_split[0].strip
    params = (command_split[1]? || "").strip

    # Verifies the permissions unless it is AUTH
    if command_words != "AUTH"
      return send_failure "not connected" if user.nil?
      return send_failure "not permitted" unless context.groups.permitted? user.as(Acl::User), cmd, Acl::Perm::Write
    end

    # Execute the operation if permitted
    handler_function = ROOT_HANDLERS[command_words]?
    return send_failure "invalid command" if handler_function.nil?
    begin
      handler_function.as(CommandHandler).call(self, params)
    rescue err
      send_failure "failed to execute command #{command_words} (#{err})"
    end
  end
end
