class FlightsController < ApplicationController
  def index
    @selected_tab = :flights
    @flight_queries = FlightQuery.all
  end
end
