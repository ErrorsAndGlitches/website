require 'hashie'
require 'set'

module Qpx
  class QpxLeg < Hashie::Dash
    include Hashie::Extensions::IgnoreUndeclared

    property :origin
    property :destination
  end

  # a segment is a trip from one place to another and consists (as far as I can tell) of a single leg, even though
  # it is a list, which is why only the first is chosen
  class QpxSegment < Hashie::Dash
    include Hashie::Extensions::IgnoreUndeclared
    include Hashie::Extensions::Dash::PropertyTranslation

    property :leg, transform_with: ->(legs) { QpxLeg.new(legs[0]) }
    property :carrier, from: :flight, with: ->(flight) { flight[:carrier] }
  end

  # slice is a trip from a starting destination to a final arrival destination which will have multiple segments
  # for connecting flights
  class QpxSlice < Hashie::Dash
    include Hashie::Extensions::Dash::PropertyTranslation
    include Hashie::Extensions::Dash::Coercion
    include Hashie::Extensions::IgnoreUndeclared

    property :segments, from: :segment, coerce: Array[QpxSegment]
  end

  class QpxTripOption < Hashie::Dash
    include Hashie::Extensions::Dash::PropertyTranslation
    include Hashie::Extensions::Dash::Coercion
    include Hashie::Extensions::IgnoreUndeclared

    SALE_TOTAL_REGEX = /([A-z]+)(\d+.\d{2})/

    property :currency, from: :saleTotal, with: ->(saleTotal) { SALE_TOTAL_REGEX.match(saleTotal)[1] }
    property :price, from: :saleTotal, with: ->(saleTotal) { SALE_TOTAL_REGEX.match(saleTotal)[2].to_i }
    property :slices, from: :slice, coerce: Array[QpxSlice]

    attr_reader :carriers

    def initialize(attributes, &block)
      super(attributes, &block)

      @carriers = Set.new
      slices.each { |slice|
        slice.segments.each { |segment|
          @carriers.add(segment.carrier)
        }
      }
    end
  end
end
