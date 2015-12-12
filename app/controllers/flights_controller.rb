class FlightsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => :flight_chart

  def index
    @selected_tab = :flights
    @trips        = Trip.all
  end

  def flight
    @selected_tab = :flights

    id    = params[:id]
    @trip = Trip.find(id)
  end

  def flight_chart
    id    = params[:id]
    @trip = Trip.find(id)
  end
end
