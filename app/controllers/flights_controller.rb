class FlightsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => :flight_chart

  def index
    @selected_tab   = :flights
    @flight_queries = FlightQuery.all
  end

  def flight
    @selected_tab = :flights

    id      = params[:id]
    @flight = FlightQuery.find(id)
  end

  def flight_chart
    id            = params[:id]
    @flight_query = FlightQuery.find(id)
  end
end
