#!/usr/bin/env ruby

require 'optparse'
require 'hashie'
require 'json'

require 'qpx/qpx_trip_builder'
require 'qpx/qpx_trip'
require 'qpx/qpx_client'

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

def createQpxTrip(config_json)
  qpx_trip_builder               = QpxTripBuilder.new
  qpx_trip_builder.adult_count   = 1
  qpx_trip_builder.max_price     = config_json.max_price
  qpx_trip_builder.num_solutions = config_json.num_solutions
  config_json.sources.each { |src|
    config_json.destinations.each { |dest|
      qpx_trip_builder.add_round_trip(src, dest, config_json.departure_date, config_json.return_date)
    }
  }
  qpx_trip_builder.build
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
qpx_client    = QpxClient.new(config_json.api_key)
qpx_trip      = createQpxTrip(config_json)
qpx_responses = qpx_client.search_flights(qpx_trip)

flight_reqs = qpx_trip.save
flight_reqs.zip(qpx_responses).each { |req, qpx_resp|
  qpx_resp.save(req)
}
