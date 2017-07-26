require "./lockable"

require "./acl/**"
require "./auth-server/**"

options = Auth::Server::Options.new
handler = Auth::Server::Handler.new options
handler.start
