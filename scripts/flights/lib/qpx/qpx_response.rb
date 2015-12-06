require 'hashie'
require 'date'

require_relative 'qpx_data'
require_relative 'qpx_trip_option'

module Qpx
  class QpxResponse < Hashie::Dash
    include Hashie::Extensions::Dash::PropertyTranslation
    include Hashie::Extensions::Dash::Coercion
    include Hashie::Extensions::IgnoreUndeclared

    property :trip_options, from: :tripOption, coerce: Array[QpxTripOption]
    property :data, coerce: QpxData

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
        flight_resp.response      = self.to_json
      }
    end

    private
    DATE_TIME_FORMAT = '%F %H:00'

    def get_formatted_query_time
      @query_time.strftime(DATE_TIME_FORMAT)
    end
  end
end
