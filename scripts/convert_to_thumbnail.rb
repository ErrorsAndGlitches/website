#!/usr/bin/env ruby
require 'crack'
require 'json'

METADATA_FILE_NAME = 'metadata'
THUMBNAIL_DIM      = 400

# read the metadata file
unless File.exists?(METADATA_FILE_NAME)
  puts "Metadata file '#{METADATA_FILE_NAME}' does not exist"
  exit(1)
end

File.open(METADATA_FILE_NAME) do |metadata_file|
  metadata = Crack::JSON.parse(metadata_file.read)

  puts JSON.pretty_generate(metadata)

  original_dir_name  = metadata['original_dir']
  thumbnail_dir_name = metadata['thumbnail_dir']

  # check if the original dir exists, create the thumbnail dir if needed
  unless File.exists?(original_dir_name)
    puts "Original images directory '#{original_dir_name}' does not exist"
    exit(1)
  end

  unless File.exists?(thumbnail_dir_name)
    begin
      Dir.mkdir(thumbnail_dir_name)
    rescue => exception
      puts "Unable to create directory #{thumbnail_dir_name} due to: #{exception}"
      exit(1)
    end
  end

  Dir.glob("#{original_dir_name}/*") do |filename|
    # convert files into smaller images if the destination image doesn't exist
    thumbnail_img_name = "#{thumbnail_dir_name}/thumbnail_#{File.basename(filename)}"
    unless File.exists?(thumbnail_img_name)
      %x(gm convert #{filename} -resize #{THUMBNAIL_DIM}x#{THUMBNAIL_DIM} #{thumbnail_img_name})
      puts "Created: #{thumbnail_img_name}"
    end
  end
end
