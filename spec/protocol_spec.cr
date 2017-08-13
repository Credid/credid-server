require "../src/auth-server/handler"

describe Auth::Server do
  it "test auth" do
    options = Auth::Server::Options.new
    users_file = Tempfile.new("protocol_test_users.yaml")
    groups_file = Tempfile.new("protocol_test_groups.yaml")
    options.users_file = users_file.path
    options.groups_file = groups_file.path
    options.verbosity = false
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
    cli.puts "USER HAS ACCESS TO : root write /any/path/random"
    cli.gets.should eq "success"
    cli.puts "USER HAS ACCESS TO : root read /any/path/random"
    cli.gets.should eq "success"
    # Test user list
    cli.puts "USER LIST"
    cli.gets.should eq "success [\"root\"]"
    # Test user add
    cli.puts "USER ADD : test test"
    cli.gets.should eq "success"
    # Test user list
    cli.puts "USER LIST"
    cli.gets.should eq "success [\"root\", \"test\"]"
    # Test user group list
    cli.puts "USER LIST GROUPS : test"
    cli.gets.should eq "success [\"user\"]"
    # Test user add group
    cli.puts "USER ADD GROUP : test gtest"
    cli.gets.should eq "success"
    # Test user group list
    cli.puts "USER LIST GROUPS : test"
    cli.gets.should eq "success [\"user\", \"gtest\"]"
    # Test user remove group
    cli.puts "USER REMOVE GROUP : test gtest"
    cli.gets.should eq "success"
    # Test user group list
    cli.puts "USER LIST GROUPS : test"
    cli.gets.should eq "success [\"user\"]"
    # Test user remove group
    cli.puts "USER REMOVE GROUP : test user"
    cli.gets.should eq "success"
    # Test user group list
    cli.puts "USER LIST GROUPS : test"
    cli.gets.should eq "success []"
    # Test user remove
    cli.puts "USER REMOVE : test"
    cli.gets.should eq "success"
    # Test user list
    cli.puts "USER LIST"
    cli.gets.should eq "success [\"root\"]"

    # Test add a new perm
    cli.puts "GROUP ADD : root read /any/path/random"
    cli.gets.should eq "success"
    cli.puts "USER HAS ACCESS TO : root write /any/path/random"
    cli.gets.should eq "failure"
    cli.puts "USER HAS ACCESS TO : root read /any/path/random"
    cli.gets.should eq "success"
    # Test remove this perm
    cli.puts "GROUP REMOVE : root /any/path/random"
    cli.gets.should eq "success"
    cli.puts "USER HAS ACCESS TO : root write /any/path/random"
    cli.gets.should eq "success"
    # Test group list
    cli.puts "GROUP LIST"
    cli.gets.should eq "success [\"root\", \"user\"]"
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
    users_file.unlink
    groups_file.unlink
  end
end
