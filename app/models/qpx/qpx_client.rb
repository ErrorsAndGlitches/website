require 'rest-client'
require 'hashie'
require 'assets/util/symbolizer'
require 'qpx/qpx_response'

class QpxClient

  def initialize(api_key)
    @api_key = api_key
  end

  def search_flights(qpx_trip)
    query_time = DateTime.now
    qpx_trip.qpx_requests.inject([]) { |responses, request|
      responses <<= parse_flight_response(query_time, post_request(request))
    }
  end

  private
  QPX_SEARCH_API_URL = 'https://www.googleapis.com/qpxExpress/v1/trips/search'
  QPX_CONTENT_TYPE   = { :content_type => 'application/json' }

  def post_request(request)
    RestClient.post(get_url, request.to_json, QPX_CONTENT_TYPE) { |response, req, result|
      case response.code
      when 200
        puts 'Successfully requested flights'
        response
      else
        puts 'Failure!'
        puts result
        puts "Url: #{req.url}"
        puts "Headers: #{req.headers}"
        puts "Payload: #{req.payload}"

        puts 'Response:'
        puts response
        exit(1)
      end
    }
  end

  def get_url
    "#{QPX_SEARCH_API_URL}?key=#{@api_key}"
  end

  def parse_flight_response(query_time, flights)
    json_flights = Hashie::Mash.new(JSON.parse(flights))
    trip_options = json_flights.trips.tripOption
    if trip_options.nil? || trip_options.empty?
      raise Exception.new('No trip options found')
    end

    QpxResponse.new(query_time, json_flights.to_json, Symbolizer.symbolize_hash(json_flights.trips))
  end
end
