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

  def save
    json_qpx_request = self.to_json
    FlightRequest.where(key: FlightRequest.get_key(json_qpx_request)).first_or_create { |qr|
      qr.raw_request = json_qpx_request
    }
  end
end
