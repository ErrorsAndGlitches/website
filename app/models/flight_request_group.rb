class FlightRequestGroup < ActiveRecord::Base
  belongs_to :trip
  belongs_to :flight_request
end
