class HomeController < ApplicationController
  def home
    @selected_tab = :home
    @links[:home] = '#'
  end
end
