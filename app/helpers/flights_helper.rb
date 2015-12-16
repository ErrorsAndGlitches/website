module FlightsHelper
  class FlightResponseSorter
    module SortType
      PRICE = lambda { |trip_opt_1, trip_opt_2|
        trip_opt_1.price <=> trip_opt_2.price
      }
    end

    attr_reader :sorted_trip_options

    def initialize(flight_responses, sort_type)
      @sorted_trip_options = {}

      flight_responses.each { |response|
        (@sorted_trip_options[response.date] ||= []).concat(response.get_response.trip_options)
      }

      @sorted_trip_options.each_value { |trip_options|
        trip_options.sort! &sort_type
      }
    end
  end
end
