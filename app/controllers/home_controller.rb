class HomeController < ApplicationController
  def home
    @selected_tab = :home
    @links
  end

  def photos
    @selected_tab = :photos
    @albums       = get_albums
  end

  def album
    @selected_tab = :photos
    @link_enabled = true

    photo_dir = params[:dir]
    @album    = get_album_thumbnails("#{PHOTO_DIR_NAME}/#{photo_dir}/#{METADATA_FILE_NAME}")
  end

  def show_photo
    @selected_tab = :photos
    @link_enabled = true

    @original_file_name = "photos/#{params[:dir]}/original/#{params[:image]}.JPG"
  end

  private

  def get_albums
    albums = []
    get_metadata_files.each do |file_name|
      File.open(file_name) do |file|
        metadata      = Crack::JSON.parse(file.read)
        album         = Hash.new
        album[:title] = metadata['title']
        album[:cover] = "#{File.dirname(file_name).slice(SLICE_REGEX)}/#{metadata['cover']}"
        album[:href]  = "/home/album/#{File.basename(File.dirname(file_name))}"
        albums << album
      end
    end

    albums
  end

  def get_album_thumbnails(metadata_file_name)
    album = Hash.new

    File.open(metadata_file_name) do |metadata_file|
      metadata = Crack::JSON.parse(metadata_file.read)

      album[:title] = metadata['title']

      thumbnail_dir    = metadata['thumbnail_dir']
      thumbnail_images = []
      Dir.glob("#{File.dirname(metadata_file_name)}/#{thumbnail_dir}/*") { |path|
        rails_path = path.slice(SLICE_REGEX)
        thumbnail_images << {
          :path => rails_path,
          :href => "#{File.basename(File.dirname(metadata_file_name))}/#{File.basename(path).sub('thumbnail_', '')}"
        }
      }

      album[:thumbnails] = thumbnail_images
    end

    album
  end

  SLICE_REGEX = /photos\/.*/
end
