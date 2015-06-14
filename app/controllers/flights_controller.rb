class FlightsController < ApplicationController
  def index
    @selected_map[:flights] = true
  end
end
