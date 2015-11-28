require 'hashie'

require_relative 'qpx_data'
require_relative 'qpx_trip_option'

class QpxResponse < Hashie::Dash
  include Hashie::Extensions::Dash::PropertyTranslation
  include Hashie::Extensions::Dash::Coercion
  include Hashie::Extensions::IgnoreUndeclared

  property :trip_options, from: :tripOption, coerce: Array[QpxTripOption]
  property :data, coerce: QpxData

  def initialize(attributes, &block)
    super(attributes, &block)
    trip_options.uniq!
    trip_options.sort! { |trip_one, trip_two|
      trip_one.price <=> trip_two.price
    }
  end

  def options_count
    trip_options.size
  end
end