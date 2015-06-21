class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  attr_accessor :selected_tab
  attr_accessor :links
  helper_method :get_albums_for_nav

  def initialize
    super
    @selected_tab = nil
    @links        = {
      :home    => {:controller => 'home', :action => 'home'},
      :photos  => {:controller => 'home', :action => 'photos'},
      :flights => {:controller => 'flights', :action => 'index'}
    }
  end

  def get_albums_for_nav
    albums = []
    get_metadata_files.each do |file_name|
      File.open(file_name) do |file|
        metadata      = Crack::JSON.parse(file.read)
        album         = Hash.new
        album[:title] = metadata['title']
        album[:href]  = "/home/album/#{File.basename(File.dirname(file_name))}"
        albums << album
      end
    end

    albums
  end

  def get_metadata_files
    Dir.glob("#{PHOTO_DIR_NAME}/**/#{METADATA_FILE_NAME}")
  end

  METADATA_FILE_NAME = 'metadata'
  PHOTO_DIR_NAME     = 'app/assets/images/photos/'
end
