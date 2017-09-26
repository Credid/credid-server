class Credid::Server::ClientHandler
  module Query
    extend self

    def apply_options_on(data : Array, options)
      if options[:count] == 0
        data
      else
        idx_start = options[:page] * options[:count]
        idx_end = idx_start + options[:count]
        data[idx_start...idx_end]
      end
    end

    def apply_options_on(data : Hash, options)
      if options[:count] == 0
        data
      else
        idx_start = options[:page] * options[:count]
        idx_end = idx_start + options[:count]
        Hash.zip data.keys[idx_start...idx_end], data.values[idx_start...idx_end]
      end
    end
  end
end
