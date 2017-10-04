require "./query"
require "./client_handler/*"

class Credid::Server::ClientHandler
  DEFAULT_OPTIONS = {
    page:  0_u64,
    count: 100_u64,
  }
  alias Options = NamedTuple(page: UInt64, count: UInt64)
  alias CommandHandler = Proc(ClientHandler, Options, String, Nil)

  macro add_handler(cmd, handler)
    ROOT_HANDLERS[{{cmd}}] = -> {{handler}}(ClientHandler, Options, String)
  end

  ROOT_HANDLERS = Hash(String, CommandHandler).new

  add_handler "AUTH", ClientHandler::CredidCommand.auth

  add_handler "USER HAS ACCESS TO", ClientHandler::UserCommand.has_access_to
  add_handler "USER LIST", ClientHandler::UserCommand.list
  add_handler "USER ADD", ClientHandler::UserCommand.add
  add_handler "USER REMOVE", ClientHandler::UserCommand.remove
  add_handler "USER REMOVE GROUP", ClientHandler::UserCommand.remove_group
  add_handler "USER ADD GROUP", ClientHandler::UserCommand.add_group
  add_handler "USER LIST GROUPS", ClientHandler::UserCommand.list_groups
  add_handler "USER CHANGE PASSWORD", ClientHandler::UserCommand.change_password

  add_handler "GROUP ADD", ClientHandler::GroupCommand.add
  add_handler "GROUP REMOVE", ClientHandler::GroupCommand.remove
  add_handler "GROUP LIST", ClientHandler::GroupCommand.list
  add_handler "GROUP LIST PERMS", ClientHandler::GroupCommand.list_perms
  add_handler "GROUP GET PERM", ClientHandler::GroupCommand.get_perm

  getter context : Handler
  getter client : OpenSSL::SSL::Socket::Server | TCPSocket
  property user : Acl::User?
  property authenticated : Bool
  getter stream : Channel(String)

  delegate users, to: context
  delegate groups, to: context

  def initialize(@context, @client, @stream = Channel::Buffered(String).new)
    @user = nil
    @authenticated = false
  end

  def connected_user : Acl::User
    raise "Not connected" if @user.nil?
    @user.as(Acl::User)
  end

  # Wait for the next command and return it when received.
  private def get_cmd
    cmd = client.gets
    client.close if cmd.nil?
    cmd
  end

  # Handle a client in a loop that fetch commands and execute them, stop on EOF.
  def start
    loop do
      cmd = get_cmd
      break if cmd.nil?
      handle_command cmd
    end
  end

  # Send data to the client.
  def send(msg : String)
    #STDERR.print "#{msg}\n"
    client.print "#{msg}\n"
    client.flush
  end

  # Send "success ..." to the client.
  def send_success(msg : String? = nil)
    success = msg ? "success #{msg}" : "success"
    STDERR.puts success
    send success
  end

  # Send "failure ..." to the client.
  def send_failure(msg : String? = nil)
    failure = msg ? "failure #{msg} : failure" : "failure"
    STDERR.puts failure
    send failure
  end

  # Extract the options of the command and
  # removes the options from the command.
  private def extract_options(cmd)
    options_hash = Hash(String, String).new

    cmd_end = cmd.index(':') || cmd.size
    while option_idx = cmd.index(/\w+=\w+/)
      option_match = cmd.match(/(?<name>\w+)=(?<value>\w+)/).as(Regex::MatchData)
      options_hash[option_match["name"]] = option_match["value"]
      option_end = option_idx + option_match[0].size
      p1 = cmd[0...option_idx].upcase
      p2 = cmd[option_end...cmd.size]
      cmd = p1 + p2
    end

    options = {
      page:  (options_hash["PAGE"]? || DEFAULT_OPTIONS[:page]).to_u64,
      count: (options_hash["COUNT"]? || DEFAULT_OPTIONS[:count]).to_u64,
    }
    {cmd, options}
  end

  private def handle_command(cmd)
    # Disconnect if needed
    if !@stream.empty? && @stream.receive? == "DISCONNECT"
      @authenticated = false
      @user = nil
      @context.update_connection self
    end


    # Handles \a
    cmd = cmd.gsub "\\a", connected_user.name unless user.nil?

    cmd, options = extract_options cmd
    command_split = cmd.split ':', 2
    command_words = command_split[0].strip
    params = (command_split[1]? || "").strip

    STDERR.print "[#{@user ? @user.as(Acl::User).name : "*undef*"}]"
    STDERR.print " => "
    STDERR.print command_words == "AUTH" ? "AUTH : #{params.split(" ").first}" : "#{cmd.inspect}"
    STDERR.print " => "

    # Verifies the permissions unless it is AUTH
    if command_words != "AUTH"
      return send_failure "not connected" if user.nil?
      return send_failure "not permitted (#{cmd})" unless context.groups.permitted? connected_user, cmd, Acl::Perm::Write, {/~/ => connected_user.name}
      # / }
    end

    # Execute the operation if permitted
    handler_function = ROOT_HANDLERS[command_words]?
    return send_failure "invalid command" if handler_function.nil?
    begin
      handler_function.as(CommandHandler).call(self, options, params)
    rescue err
      send_failure "cannot execute command #{command_words} (#{err})"
    end
  end
end
