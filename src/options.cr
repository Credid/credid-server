require "option_parser"

module Auth::Server
  class Options
    getter port : UInt16
    getter ip : String
    getter ssl : Bool
    getter ssl_key_file : String
    getter ssl_cert_file : String
    getter users_file : String
    getter acls_file : String

    def initialize
      @port = 8999_u16
      @ip = "127.0.0.1"
      @ssl = false
      @ssl_key_file = "private.key"
      @ssl_cert_file = "cert.pem"
      @users_file = "users.yaml"
      @acls_file = "acls.yaml"
      OptionParser.parse! do |parser|
        parser.banner = "Usage: auth-server [arguments]"
        parser.on("-p=PORT", "--port=PORT", "Specify the port to bind") { |port| @port = UInt16.new port }
        parser.on("-i=IP", "--ip=IP", "Specify the network interface") { |ip| @ip = ip }
        parser.on("-s", "--secure", "Enable SSL") { @ssl = true }
        parser.on("--ssl-key=FILE", "Specify the key file") { |key| @ssl_key_file = key }
        parser.on("--ssl-cert=FILE", "Specify the cert file") { |cert| @ssl_cert_file = cert }
        parser.on("-u=UFILE", "--users=FILE", "Specify the users database file") { |f| @users_file = f }
        parser.on("-a=AFILE", "--acls=FILE", "Specify the acls database file") { |f| @acls_file = f }
        parser.on("-h", "--help", "Show this help") { puts parser; exit }
      end
    end
  end
end
