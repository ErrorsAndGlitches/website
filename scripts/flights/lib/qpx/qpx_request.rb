require 'hashie'

class QpxPassengerList < Hashie::Dash
  property :kind
  property :adultCount
  property :childCount
  property :infantInLapCount
  property :infantInSeatCount
  property :seniorCount
end

class QpxRequestSlice < Hashie::Dash
  property :kind
  property :origin
  property :destination
  property :date
  property :maxStops
  property :maxConnectionDuration
  property :preferredCabin
end

class QpxRequestData < Hashie::Dash
  include Hashie::Extensions::Dash::Coercion

  property :saleCountry
  property :maxPrice
  property :solutions
  property :passengers, coerce: QpxPassengerList
  property :slice, coerce: Array[QpxRequestSlice]
end

class QpxRequest < Hashie::Dash
  include Hashie::Extensions::Dash::Coercion

  property :request, coerce: QpxRequestData
end
