class HomeController < ApplicationController
  def home
    @selected_map[:home] = true
  end

  def photos
    @selected_map[:photos] = true
  end
end
