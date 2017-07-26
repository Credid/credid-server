class Auth::Server::ClientHandler
  getter context : Handler
  getter client : OpenSSL::SSL::Socket::Server | TCPSocket
  property user : String?
  property password : String?
  property authenticated : Bool

  def initialize(@context, @client)
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

  private def handle_command(cmd)
    puts "received: \"#{cmd}\""
    @client.puts ":#{cmd}"
    @client.puts context.users.inspect
    @client.puts context.acls.inspect
    puts "sent :\":#{cmd}\""
  end
end
