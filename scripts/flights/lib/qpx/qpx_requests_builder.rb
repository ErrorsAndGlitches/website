require 'ostruct'
require_relative 'qpx_request'

class QpxRequestsBuilder
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

  attr_accessor :adult_count, :child_count, :infant_in_lap_count, :infant_in_seat_count, :senior_count,
                :sale_country, :max_stops, :max_connection_duration, :preferred_cabin, :max_price, :num_solutions

  attr_reader :trips

  DEFAULT_MAX_STOPS         = 1
  DEFAULT_MAX_CONN_DURATION = 600 # minutes -> 10 hours

  def initialize
    @adult_count = @child_count = @infant_in_lap_count = @infant_in_seat_count = @senior_count = 0
    @max_price   = @num_solutions = 0

    @sale_country            = SaleCountry::US
    @max_stops               = DEFAULT_MAX_STOPS
    @max_connection_duration = DEFAULT_MAX_CONN_DURATION
    @preferred_cabin         = CabinType::COACH
    @trips                   = []
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
    qpx_requests = []

    qpx_passenger_list = create_passenger_list
    trips.each { |trip|
      qpx_requests <<= {
        :request => {
          :passengers  => qpx_passenger_list,
          :slice       => create_qpx_slices(trip),
          :saleCountry => sale_country,
          :maxPrice    => "#{SaleCountry.get_currency(sale_country)}#{max_price}",
          :solutions   => num_solutions
        }
      }
    }

    qpx_requests.inject([]) { |qpx_reqs, qpx_req|
      qpx_reqs <<= QpxRequest.new(qpx_req)
    }
  end

  private
  QPX_PASSENGER_KIND = 'qpxexpress#passengerCounts'
  QPX_SLICE_KIND     = 'qpxexpress#sliceInput'

  def create_passenger_list
    {
      :kind              => QPX_PASSENGER_KIND,
      :adultCount        => adult_count,
      :childCount        => child_count,
      :infantInLapCount  => infant_in_lap_count,
      :infantInSeatCount => infant_in_seat_count,
      :seniorCount       => senior_count
    }
  end

  def create_qpx_slices(trip)
    slices = []
    unless trip.departure_date.nil?
      slices <<= {
        :kind                  => QPX_SLICE_KIND,
        :origin                => trip.origin,
        :destination           => trip.destination,
        :date                  => trip.departure_date,
        :maxStops              => max_stops,
        :maxConnectionDuration => max_connection_duration,
        :preferredCabin        => preferred_cabin
      }
    end
    unless trip.return_date.nil?
      slices <<= {
        :kind                  => QPX_SLICE_KIND,
        :origin                => trip.destination,
        :destination           => trip.origin,
        :date                  => trip.return_date,
        :maxStops              => max_stops,
        :maxConnectionDuration => max_connection_duration,
        :preferredCabin        => preferred_cabin
      }
    end

    slices
  end
end
