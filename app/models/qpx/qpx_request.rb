require 'hashie'
require 'assets/util/symbolizer'

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

  def self.from_string(str)
    QpxRequest.new(Symbolizer.symbolize_hash(JSON.parse(str)))
  end

  def save
    FlightRequest.where(key: get_key).first_or_create { |fr|
      fr.qpx_request = self
    }
  end

  def get_key
    XXhash.xxh64(self.to_json)
  end

  def get_source
    self.request.slice.first.origin
  end

  def get_destination
    self.request.slice.first.destination
  end

  def get_departure_date
    self.request.slice.first.date
  end

  def get_return_date
    if self.request.slice.size == 1
      return nil
    end

    self.request.slice.last.date
  end
end
