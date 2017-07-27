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
    cli.puts "USER LIST GROUPS : root"
    cli.gets.should eq "success [\"root\"]"
    # Test basic perms
    cli.puts "USER HAS ACCESS TO : write /any/path/random"
    cli.gets.should eq "success"
    cli.puts "USER HAS ACCESS TO : read /any/path/random"
    cli.gets.should eq "success"
    # Test user add
    cli.puts "USER ADD : test test"
    cli.gets.should eq "success"
    # Test user group list
    cli.puts "USER LIST GROUPS : test"
    cli.gets.should eq "success []"
    # Test user add group
    cli.puts "USER ADD GROUP : test gtest"
    cli.gets.should eq "success"
    # Test user group list
    cli.puts "USER LIST GROUPS : test"
    cli.gets.should eq "success [\"gtest\"]"
    # Test user remove group
    cli.puts "USER REMOVE GROUP : test gtest"
    cli.gets.should eq "success"
    # Test user group list
    cli.puts "USER LIST GROUPS : test"
    cli.gets.should eq "success []"
    # Test user remove
    cli.puts "USER REMOVE : test"
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
    # test group get perm
    cli.puts "GROUP GET PERM : root *"
    cli.gets.should eq "success \"Write\""
    cli.puts "GROUP GET PERM : root /not/exists"
    cli.gets.should eq "success \"None\""
    cli.puts "GROUP GET PERM : randomgroup /not/exists"
    cli.gets.should eq "success \"None\""
    cli.close
    handler.stop
  end
end
