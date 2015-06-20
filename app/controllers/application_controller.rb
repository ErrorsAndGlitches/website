class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  attr_accessor :selected_map

  helper_method :get_nav_link

  def initialize
    super
    @selected_tab = nil
    @link_enabled = false
  end

  def get_nav_link(controller, action, id)
    is_selected = @selected_tab == id.to_sym

    if is_selected
      navbar_class = 'navbar-selected'
    else
      navbar_class = 'navbar-unselected'
    end

    if @link_enabled
      options = {:controller => controller, :action => action}
    else
      options = '#'
    end

    view_context.link_to options, :class => 'navbar-link' do
      view_context.content_tag(:div, '', :id => id, :class => navbar_class)
    end
  end
end
