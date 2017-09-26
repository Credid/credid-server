require "./_init"

options = Credid::Server::Options.new.parse!
handler = Credid::Server::Handler.new options
handler.start
