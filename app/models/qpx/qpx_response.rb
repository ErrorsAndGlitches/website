require 'hashie'
require 'date'

require 'qpx/qpx_data'
require 'qpx/qpx_trip_option'
require 'assets/symbolizer'

class QpxResponse < Hashie::Dash
  include Hashie::Extensions::Dash::PropertyTranslation
  include Hashie::Extensions::Dash::Coercion
  include Hashie::Extensions::IgnoreUndeclared

  property :trip_options, from: :tripOption, coerce: Array[QpxTripOption]
  property :data, coerce: QpxData

  def self.from_string(query_time, response)
    QpxResponse.new(query_time, nil, Symbolizer.symbolize_hash(JSON.parse(response)))
  end

  def initialize(query_time, full_response, attributes, &block)
    super(attributes, &block)
    @query_time    = query_time
    @full_response = full_response

    trip_options.uniq!
    trip_options.sort! { |trip_one, trip_two|
      trip_one.price <=> trip_two.price
    }
  end

  def save(flight_request)
    date = get_formatted_query_time
    flight_request.flight_responses.where(date: date).first_or_create { |flight_resp|
      flight_resp.date          = date
      flight_resp.full_response = @full_response
      flight_resp.response      = self
    }
  end

  private
  DATE_TIME_FORMAT = '%F %H:00'

  def get_formatted_query_time
    @query_time.strftime(DATE_TIME_FORMAT)
  end
end
