describe Auth::Server do
  it "test auth" do
    options = Auth::Server::Options.new
    handler = Auth::Server::Handler.new options
    server_fiber = spawn { handler.start }

    sleep 0.2
    cli = TCPSocket.new "127.0.0.1", 8999
    # Auth
    cli.puts "AUTH : root toor"
    cli.gets(chomp: false).should eq "success\n"
    # Test basic groups
    cli.puts "USER LIST GROUPS : \\a"
    cli.gets.should eq "success [\"root\"]"
    # Test basic perms
    cli.puts "USER HAS ACCESS TO : write /any/path/random"
    cli.gets.should eq "success"
    cli.puts "USER HAS ACCESS TO : read /any/path/random"
    cli.gets.should eq "success"
    # Test add a new perm
    cli.puts "GROUP ADD : root read /any/path/random"
    cli.gets.should eq "success"
    cli.puts "USER HAS ACCESS TO : write /any/path/random"
    cli.gets.should eq "failure"
    cli.puts "USER HAS ACCESS TO : read /any/path/random"
    cli.gets.should eq "success"
    # Test remove this perm
    cli.puts "GROUP REMOVE : root /any/path/random"
    cli.gets.should eq "success"
    cli.puts "USER HAS ACCESS TO : write /any/path/random"
    cli.gets.should eq "success"
    # Test group list
    cli.puts "GROUP LIST"
    cli.gets.should eq "success [\"root\"]"
    # Test group list perm
    cli.puts "GROUP LIST PERMS : root"
    cli.gets.should eq "success {\"*\" => \"Write\"}"

    cli.close
    handler.stop
  end
end
