class FlightsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => :flight_chart

  def index
    @selected_tab = :flights
    @trips        = get_sorted_trips
  end

  def flight
    @selected_tab = :flights

    id    = params[:id]
    @trip = Trip.find(id)
  end

  def flight_chart
    id    = params[:id]
    @trip = Trip.find(id)

    sort_type            = FlightsHelper::FlightResponseSorter::SortType::PRICE
    @sorted_trip_options = FlightsHelper::FlightResponseSorter.new(@trip.flight_responses, sort_type).sorted_trip_options
  end
end
