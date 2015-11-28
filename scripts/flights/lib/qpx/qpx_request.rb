require 'hashie'
require 'ostruct'

class QpxRequest < Hashie::Clash

  module SaleCountry
    US = :US

    def self.get_currency(sale_country)
      CURRENCY_MAP[sale_country]
    end

    private
    CURRENCY_MAP = {
      US => 'USD'
    }
  end

  module CabinType
    COACH = :COACH
  end

  class Builder
    attr_accessor :adult_count, :child_count, :infant_in_lap_count, :infant_in_seat_count, :senior_count,
                  :sale_country, :max_stops, :max_connection_duration, :preferred_cabin, :max_price, :num_solutions

    attr_reader :trips

    DEFAULT_MAX_STOPS         = 1
    DEFAULT_MAX_CONN_DURATION = 600 # minutes -> 10 hours

    def initialize
      @adult_count = @child_count = @infant_in_lap_count = @infant_in_seat_count = @senior_count = 0
      @max_price   = @num_solutions = 0

      @sale_country            = QpxRequest::SaleCountry::US
      @max_stops               = DEFAULT_MAX_STOPS
      @max_connection_duration = DEFAULT_MAX_CONN_DURATION
      @preferred_cabin         = QpxRequest::CabinType::COACH
      @trips = []
    end

    def add_trip(origin, destination, date)
      add_round_trip(origin, destination, date, nil)
    end

    def add_round_trip(origin, destination, departure_date, return_date)
      trip                = OpenStruct.new
      trip.origin         = origin
      trip.destination    = destination
      trip.departure_date = departure_date
      trip.return_date    = return_date
      @trips              <<= trip
    end

    def build
      QpxRequest.new(self)
    end
  end

  def each
    @requests.each { |request|
      yield request
    }
  end

  private
  QPX_PASSENGER_KIND = 'qpxexpress#passengerCounts'
  QPX_SLICE_KIND     = 'qpxexpress#sliceInput'

  def initialize(builder)
    @requests = []

    passengers = Hashie::Clash.new
                   .kind(QPX_PASSENGER_KIND)
                   .adultCount(builder.adult_count)
                   .childCount(builder.child_count)
                   .infantInLapCount(builder.infant_in_lap_count)
                   .infantInSeatCount(builder.infant_in_seat_count)
                   .seniorCount(builder.senior_count)

    builder.trips.each { |trip|
      @requests <<= Hashie::Clash.new.request(
        Hashie::Clash.new
          .passengers(passengers)
          .slice(create_trips(builder, trip))
          .saleCountry(builder.sale_country)
          .maxPrice("#{SaleCountry.get_currency(builder.sale_country)}#{builder.max_price}")
          .solutions(builder.num_solutions)
      )
    }
  end

  def create_trips(builder, trip)
    trips = []
    unless trip.departure_date.nil?
      trips <<= {
        :kind                  => QPX_SLICE_KIND,
        :origin                => trip.origin,
        :destination           => trip.destination,
        :date                  => trip.departure_date,
        :maxStops              => builder.max_stops,
        :maxConnectionDuration => builder.max_connection_duration,
        :preferredCabin        => builder.preferred_cabin
      }
    end
    unless trip.return_date.nil?
      trips <<= {
        :kind                  => QPX_SLICE_KIND,
        :origin                => trip.destination,
        :destination           => trip.origin,
        :date                  => trip.return_date,
        :maxStops              => builder.max_stops,
        :maxConnectionDuration => builder.max_connection_duration,
        :preferredCabin        => builder.preferred_cabin
      }
    end

    trips
  end
end
