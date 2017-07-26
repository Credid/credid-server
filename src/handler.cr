require "socket"
require "openssl"
require "../users/users"
require "../acl/groups"

require "./options"
require "./client_handler"

class Auth::Server::Handler
  getter options : Auth::Server::Options
  getter users : Users
  getter acls : Acl::Groups

  def initialize(@options)
    @users = Users.new(@options.users_file).load!
    @acls = Acl::Groups.new(@options.acls_file).load!
    @users.register! name: "root", password: "toor", groups: %w(root) if @users.list.empty?
    if @acls.groups.empty?
      @acls.add "toor"
      @acls["toor"]["*"] = Acl::Perm::Write
      @acls.save!
    end
  end

  def start
    socket = TCPServer.new @options.ip, @options.port
    if @options.ssl
       context = OpenSSL::SSL::Context::Server.new
       context.private_key = @options.ssl_key_file
       context.certificate_chain = @options.ssl_cert_file
       loop { spawn handle_client(socket, socket.accept, context) }
    else
       loop { spawn handle_client(socket, socket.accept) }
    end
  end

  private def handle_client(socket, client, context = nil)
    client = OpenSSL::SSL::Socket::Server.new client, context if context
    ClientHandler.new(self, client).handle
  end
end
