class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  attr_accessor :selected_tab
  attr_accessor :links
  helper_method :get_albums_for_nav
  helper_method :get_sorted_trips

  def initialize
    super
    @selected_tab = nil
    @links        = {
      :home    => { :controller => 'home', :action => 'home' },
      :albums  => { :controller => 'albums', :action => 'index' },
      :flights => { :controller => 'flights', :action => 'index' }
    }
  end

  def get_albums_for_nav
    Album.order(:date)
  end

  def get_sorted_trips
    Trip.all.to_a.sort! { |trip_one, trip_two|
      trip_one.get_departure_date <=> trip_two.get_departure_date
    }
  end
end
