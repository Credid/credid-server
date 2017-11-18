require "Termioshelp"
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

    output.print "Choose the administrator (#{root_username}) password: "
    output.flush
    root_password = Termioshelp::Password.use(stream) do
      stream.gets rescue nil
    end
    raise "No password provided" if root_password.nil? || root_password.empty?

    handler.users.register! name: root_username, password: root_password, groups: [root_groupname], cost: handler.options.password_cost
    handler.groups.add root_groupname
    handler.groups[root_groupname]["*"] = Acl::Perm::Write
    handler.groups.save!

    output.puts
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

    output.puts
    output.puts "The group #{default_groupname} has now (Write => USER CHANGE PASSWORD : ~ *)"
    output.puts "The group #{default_groupname} has now (Write => USER REMOVE : ~)"
    output.puts "The group #{default_groupname} has now (Write => USER LIST GROUP : ~)"
  end
end
