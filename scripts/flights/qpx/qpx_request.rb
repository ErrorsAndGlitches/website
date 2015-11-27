require 'hashie'
require 'ostruct'

class QpxRequest < Hashie::Clash

  module SaleCountry
    US = :US
  end

  module CabinType
    COACH = :COACH
  end

  class Builder
    attr_accessor :adult_count, :child_count, :infant_in_lap_count, :infant_in_seat_count, :senior_count,
                  :sale_country, :max_stops, :max_connection_duration, :preferred_cabin

    attr_reader :trips

    DEFAULT_MAX_STOPS         = 1
    DEFAULT_MAX_CONN_DURATION = 600 # minutes -> 10 hours

    def initialize
      @adult_count             = @child_count = @infant_in_lap_count = @infant_in_seat_count = @senior_count = 0
      @sale_country            = QpxRequest::SaleCountry::US
      @max_stops               = DEFAULT_MAX_STOPS
      @max_connection_duration = DEFAULT_MAX_CONN_DURATION
      @preferred_cabin         = QpxRequest::CabinType::COACH
      @trips                   = []
    end

    def add_trip(origin, destination, date)
      trip             = OpenStruct.new
      trip.origin      = origin
      trip.destination = destination
      trip.date        = date
      @trips           <<= trip
    end

    def build
      QpxRequest.new(self)
    end
  end

  private
  QPX_PASSENGER_KIND = 'qpxexpress#passengerCounts'
  QPX_SLICE_KIND     = 'qpxexpress#sliceInput'

  def initialize(builder)
    super({}, nil)

    passengers = Hashie::Clash.new
                   .kind(QPX_PASSENGER_KIND)
                   .adultCount(builder.adult_count)
                   .childCount(builder.child_count)
                   .infantInLapCount(builder.infant_in_lap_count)
                   .infantInSeatCount(builder.infant_in_seat_count)
                   .seniorCount(builder.senior_count)

    request = Hashie::Clash.new
                .passengers(passengers)
                .slice(create_trips(builder))
                .saleCountry(builder.sale_country)

    self.request(request)
  end

  def create_trips(builder)
    builder.trips.inject([]) { |memo, trip|
      memo <<= {
        :kind                  => QPX_SLICE_KIND,
        :origin                => trip.origin,
        :destination           => trip.destination,
        :date                  => trip.date,
        :maxStops              => builder.max_stops,
        :maxConnectionDuration => builder.max_connection_duration,
        :preferredCabin        => builder.preferred_cabin
      }
    }
  end
end
