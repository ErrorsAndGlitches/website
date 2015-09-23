class FlightEndpoint < ActiveRecord::Base
  belongs_to :flight_query
  belongs_to :airport
end
