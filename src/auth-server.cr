require "./_init"

options = Auth::Server::Options.new
handler = Auth::Server::Handler.new options
handler.start
