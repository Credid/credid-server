require "./_init"

options = Auth::Server::Options.new.parse!
handler = Auth::Server::Handler.new options
handler.start
