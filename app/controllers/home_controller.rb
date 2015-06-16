class HomeController < ApplicationController
  def home
    @selected_map[:home] = true
  end

  def photos
    @selected_map[:photos] = true

    # read metadata file and get the original files
    metadata_file_name          = "#{@@PHOTO_DIR}/metadata"
    if File.exists? (metadata_file_name)
      File.open(metadata_file_name) do |metadata_file|
        metadata      = Crack::JSON.parse(metadata_file.read)
        @title = metadata['title']

        thumbnail_dir = metadata['thumbnail_dir']
        @image_paths  = Dir.glob("#{@@PHOTO_DIR}/#{thumbnail_dir}/*").map { |path|
          path.slice(/photos\/.*/)
        }
      end
    else
      @image_paths = []
    end
  end

  private

  @@IMAGE_DIR = 'app/assets/images/'
  @@PHOTO_DIR = "#{@@IMAGE_DIR}/photos/hike_10-5-2015/"
end
