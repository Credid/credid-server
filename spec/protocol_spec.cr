describe Auth::Server do
  it "test auth" do
    options = Auth::Server::Options.new
    handler = Auth::Server::Handler.new options
    server_fiber = spawn { handler.start }

    sleep 0.2
    cli = TCPSocket.new "127.0.0.1", 8999
    cli.puts "AUTH : root toor"
    cli.gets.should eq "success"
    cli.puts "USER HAS ACCESS TO : write /any/path/random"
    cli.gets.should eq "success"
    cli.puts "USER HAS ACCESS TO : read /any/path/random"
    cli.gets.should eq "success"

    cli.close
    handler.stop
  end
end
