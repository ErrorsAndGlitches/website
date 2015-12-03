require 'hashie'

module Qpx
  class QpxAirport < Hashie::Dash
    include Hashie::Extensions::Dash::PropertyTranslation
    include Hashie::Extensions::IgnoreUndeclared

    property :acronym, from: :code
    property :name
  end

  class QpxCarrier < Hashie::Dash
    include Hashie::Extensions::IgnoreUndeclared

    property :code
    property :name
  end

# order of PropertyTranslation before Coercion is important!
  class QpxData < Hashie::Dash
    include Hashie::Extensions::Dash::PropertyTranslation
    include Hashie::Extensions::Dash::Coercion
    include Hashie::Extensions::IgnoreUndeclared

    property :airports, coerce: Array[QpxAirport], from: :airport
    property :carriers, coerce: Array[QpxCarrier], from: :carrier
  end
end
