require "./lockable"
require "./options"
require "./handler"

#require "./acl/**"
#require "./users/**"
require "./auth-server/**"

options = Auth::Server::Options.new
handler = Auth::Server::Handler.new options
handler.start
