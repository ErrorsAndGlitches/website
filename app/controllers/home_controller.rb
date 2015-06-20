class HomeController < ApplicationController
  def home
    @selected_map[:home] = true
  end

  def photos
    @selected_map[:photos] = true

    # find directories with the 'metadata' file
    @albums                = []
    Dir.glob("#{PHOTO_DIR_NAME}/**/#{METADATA_FILE_NAME}") do |metadata_file_name|
      add_images(metadata_file_name)
    end
  end

  def show_photo
    @original_file_name = 'photos/' + params[:id].sub('thumbnail_', '').sub('thumbnail', 'original') + '.JPG'
  end

  private

  def add_images(metadata_file_name)
    File.open(metadata_file_name) do |metadata_file|
      metadata = Crack::JSON.parse(metadata_file.read)

      album         = Hash.new
      album[:title] = metadata['title']

      thumbnail_dir      = metadata['thumbnail_dir']
      thumbnail_images   = []
      Dir.glob("#{File.dirname(metadata_file_name)}/#{thumbnail_dir}/*") { |path|
        thumbnail_images << path.slice(/photos\/.*/)
      }
      album[:thumbnails] = thumbnail_images

      @albums << album
    end
  end

  METADATA_FILE_NAME = 'metadata'
  PHOTO_DIR_NAME     = 'app/assets/images/photos/'
end
