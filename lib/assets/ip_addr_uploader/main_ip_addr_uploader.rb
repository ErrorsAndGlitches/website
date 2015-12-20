require 'assets/util/logger'

require_relative 'ip_address_querier'
require_relative 'ip_addr_cache'
require_relative 's3_ip_addr_uploader'

class UploaderOptions
  def self.parse(args)
    options    = {}
    opt_parser = OptionParser.new { |opts|
      opts.banner = "Usage #{File.basename($0)} [options]"

      opts.on('-c', '--config=CONFIG', 'JSON configuration for uploading the IP address') do |config_file|
        options[:config_file] = config_file
      end

      opts.on('-h', '--help', 'Show the help message') do
        puts opts
        exit
      end
    }

    opt_parser.parse!(args)
    options
  end
end

if ARGV.empty?
  UploaderOptions.parse(%w[-h])
end

options = UploaderOptions.parse(ARGV)
if options[:config_file].nil?
  raise OptionParser::MissingArgument, 'Missing configuration argument'
end

unless File.exists?(options[:config_file])
  raise Exception, "#{options[:config_file]} does not exist"
end

config_json = Hashie::Mash.new(JSON.parse(File.read(options[:config_file])))
if config_json.region.nil? || config_json.bucket_name.nil? || config_json.file_name.nil?
  Logger.log(self, 'Missing required information in the json configuration file')
  exit 1
end

ip_addr_querier = IpAddressQuerier.new
ip_addr_cache   = IpAddrCache.new(config_json.cache_dir)

ip_addr = ip_addr_querier.get_addr
if !ip_addr.eql?(ip_addr_cache.get)
  Logger.log(self, 'Uploading ip address to S3')

  s3_ip_addr_uploader = S3IpAddrUploader.new(config_json.region, config_json.bucket_name, config_json.file_name)
  s3_ip_addr_uploader.upload_ip_addr(ip_addr)
  ip_addr_cache.set(ip_addr)
else
  Logger.log(self, 'Not uploading to S3 because the cached address is the same')
end
