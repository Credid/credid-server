require "./options"
require "./handler"

module Credid::Server::Configure
  extend self
  def root!(handler : Credid::Server::Handler)
    raise "Users are already initialized" unless handler.users.list.empty?

    stream = STDIN
    output = STDOUT

    output.print "Choose the name of the administrator group [root]: "
    output.flush
    root_groupname = stream.gets || "root"
    root_groupname = "root" if root_groupname.empty?

    output.print "Choose the administrator username [root]: "
    output.flush
    root_username = stream.gets || "root"
    root_username = "root" if root_username.empty?

    # Init the termios
    told = LibC::Termios.new
    ret = LibC.tcgetattr(stream.fd, pointerof(told))
    raise "Failed to get attr" if ret != 0

    # Save current the current state of the termios
    tnew = told

    # Disable password display
    tnew.c_lflag &= ~LibC::ECHO
    ret = LibC.tcsetattr(stream.fd, LibC::TCSAFLUSH, pointerof(tnew))
    raise "Failed to set attr" if ret != 0

    output.print "Choose the administrator (#{root_username}) password: "
    output.flush
    root_password = stream.gets
    raise "No password provided" if root_password.nil? || root_password.empty?

    # Reset the termios
    ret = LibC.tcsetattr(stream.fd, LibC::TCSAFLUSH, pointerof(told))

    handler.users.register! name: root_username, password: root_password, groups: [root_groupname], cost: handler.options.password_cost
    handler.groups.add root_groupname
    handler.groups[root_groupname]["*"] = Acl::Perm::Write
    handler.groups.save!

    output.puts "The admin (#{root_username}) in the group (#{root_groupname}) has been added with (Write => *)"
  end

  def default_group!(handler : Credid::Server::Handler)
    raise "Groups are already initialized" unless handler.groups.groups.empty?

    stream = STDIN
    output = STDOUT

    output.print "Choose the name of the default user group [user]: "
    output.flush
    default_groupname = stream.gets || "user"
    default_groupname = "user" if default_groupname.empty?

    handler.groups.add default_groupname
    handler.groups[default_groupname]["USER CHANGE PASSWORD : ~ *"] = Acl::Perm::Write
    handler.groups[default_groupname]["USER REMOVE : ~"] = Acl::Perm::Write
    handler.groups[default_groupname]["USER LIST GROUPS : ~"] = Acl::Perm::Write
    handler.groups.save!

    output.puts "The group #{default_groupname} has now (Write => USER CHANGE PASSWORD : ~ *)"
    output.puts "The group #{default_groupname} has now (Write => USER REMOVE : ~)"
    output.puts "The group #{default_groupname} has now (Write => USER LIST GROUP : ~)"
  end
end
