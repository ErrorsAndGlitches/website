class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  attr_accessor :selected_map

  def initialize
    super
    @selected_map = Hash.new(false)
  end
end
