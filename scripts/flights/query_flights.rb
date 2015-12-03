#!/usr/bin/env ruby

require 'optparse'
require 'hashie'
require 'json'

require_relative 'lib/qpx/qpx_requests_builder'
require_relative 'lib/qpx/qpx_request'
require_relative 'lib/qpx/qpx_client'

class FlightQueryOptionsParser
  def self.parse(args)
    options    = {}
    opt_parser = OptionParser.new { |opts|
      opts.banner = "Usage #{File.basename($0)} [options]"

      opts.on('-c', '--config=CONFIG', 'JSON flight configuration file') do |config_file|
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

def createQpxRequests(config_json)
  qpx_reqs_builder               = Qpx::QpxRequestsBuilder.new
  qpx_reqs_builder.adult_count   = 1
  qpx_reqs_builder.max_price     = config_json.max_price
  qpx_reqs_builder.num_solutions = config_json.num_solutions
  config_json.sources.each { |src|
    config_json.destinations.each { |dest|
      qpx_reqs_builder.add_round_trip(src, dest, config_json.departure_date, config_json.return_date)
    }
  }
  qpx_reqs_builder.build
end

########################################################################################################################
# Check required options are provided
#
if ARGV.empty?
  FlightQueryOptionsParser.parse(%w[-h])
end

options = FlightQueryOptionsParser.parse(ARGV)
if options[:config_file].nil?
  raise OptionParser::MissingArgument, 'Missing configuration argument'
end

unless File.exists?(options[:config_file])
  raise Exception, "#{options[:config_file]} does not exist"
end

config_json   = Hashie::Mash.new(JSON.parse(File.read(options[:config_file])))
qpx_client    = Qpx::QpxClient.new(config_json.api_key)
qpx_requests  = createQpxRequests(config_json)
qpx_responses = qpx_client.search_flights(qpx_requests)

qpx_responses.each { |qpx_resp|
  qpx_resp.save
}
