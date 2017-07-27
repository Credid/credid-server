require "option_parser"

module Auth::Server
  class Options
    property port : UInt16
    property ip : String
    property ssl : Bool
    property ssl_key_file : String
    property ssl_cert_file : String
    property users_file : String
    property groups_file : String
    property verbosity : Bool

    def initialize
      @port = 8999_u16
      @ip = "127.0.0.1"
      @ssl = false
      @ssl_key_file = "private.key"
      @ssl_cert_file = "cert.pem"
      @users_file = "users.yaml"
      @groups_file = "groups.yaml"
      @verbosity = true
    end

    def parse!
      OptionParser.parse! do |parser|
        parser.banner = "Usage: auth-server <server-options>"
        parser.on("-p=PORT", "--port=PORT", "Specify the port to bind") { |port| @port = UInt16.new port }
        parser.on("-i=IP", "--ip=IP", "Specify the network interface") { |ip| @ip = ip }
        parser.on("-s", "--secure", "Enable SSL") { @ssl = true }
        parser.on("--ssl-key=FILE", "Specify the key file") { |key| @ssl_key_file = key }
        parser.on("--ssl-cert=FILE", "Specify the cert file") { |cert| @ssl_cert_file = cert }
        parser.on("-u=UFILE", "--users=FILE", "Specify the users database file") { |f| @users_file = f }
        parser.on("-a=AFILE", "--groups=FILE", "Specify the groups database file") { |f| @groups_file = f }
        parser.on("-q", "--quiet", "Disable verbosity") { |v| @verbosity = false }
        parser.on("-h", "--help", "Show this help") { puts parser; exit }
      end
      self
    end
  end
end
