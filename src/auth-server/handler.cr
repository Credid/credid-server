require "socket"
require "openssl"

require "./options"
require "./client_handler"

class Auth::Server::Handler
  getter options : Auth::Server::Options
  getter users : Acl::Users
  getter groups : Acl::Groups
  # Used to close the server during the execution
  @socket : TCPSocket?

  def initialize(@options)
    @users = Acl::Users.new(@options.users_file).load!
    @groups = Acl::Groups.new(@options.groups_file).load!
    initialize_default_configuration!
  end

  def initialize_default_configuration!
    @users.register! name: "root", password: "toor", groups: %w(root) if @users.list.empty?
    if @groups.groups.empty?
      @groups.add "root"
      @groups["root"]["*"] = Acl::Perm::Write
      @groups.add "user"
      # @groups["user"]["USER CHANGE PASSWORD : \\u *"] = Acl::Perm::Write
      # @groups["user"]["USER REMOVE : \\u"] = Acl::Perm::Write
      # @groups["user"]["USER LIST GROUPS : \\u"] = Acl::Perm::Write
      @groups.save!
    end
  end

  def start
    server = TCPServer.new @options.ip, @options.port
    @socket = server
    puts "Auth-Server started on #{@options.ip}:#{@options.port} (#{@options.ssl ? "secure" : "unsecure"})" if @options.verbosity

    context = nil
    if @options.ssl
      context = OpenSSL::SSL::Context::Server.new
      context.private_key = @options.ssl_key_file
      context.certificate_chain = @options.ssl_cert_file
    end

    loop do
      if client = server.accept?
        spawn handle_client(server, client, context)
      else
        break
      end
    end
  end

  # TODO: check ssl socket too
  def stop
    @socket.as(TCPServer).close unless @socket.nil?
  end

  private def handle_client(socket, client, ssl_context = nil)
    puts "New client connected" if @options.verbosity
    if ssl_context
      ssl_client = OpenSSL::SSL::Socket::Server.new client, ssl_context
      ClientHandler.new(self, ssl_client).handle
    else
      ClientHandler.new(self, client).handle
    end
  end
end
