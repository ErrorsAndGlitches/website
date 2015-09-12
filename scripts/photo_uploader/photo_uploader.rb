#!/usr/bin/env ruby

require 'pathname'
require 'optparse'

require_relative 'lib_photo_update/s3_photo_client'
require_relative 'lib_photo_update/album'
require_relative 'lib_photo_update/photo_db'

THUMBNAIL_SIZE = 400
REGION         = 'us-west-2'
S3_BASE_LINK   = 'https://s3-us-west-2.amazonaws.com'

class PhotosOptionsParser
  def self.parse(args)
    options    = {}
    opt_parser = OptionParser.new { |opts|
      opts.banner = "Usage #{$0} [options]"

      opts.on('-c', '--mysql_config=CONFIG', 'MySQL JSON configuration file') do |config_file|
        options[:config_file] = config_file
      end

      opts.on('-m', '--metadata=FILE', 'Metadata file') do |metafile|
        options[:metafile] = metafile
      end

      opts.on('-h', '--help', 'Show the help message') do
        puts opts
        exit
      end
    }

    opt_parser.parse!(args)
    options
  end
end

########################################################################################################################
# Check required options are provided
#
if ARGV.empty?
  PhotosOptionsParser.parse(%w[-h])
end

options = PhotosOptionsParser.parse(ARGV)
if options[:metafile].nil? || options[:config_file].nil?
  raise OptionParser::MissingArgument, 'Missing directory or configuration argument'
end

########################################################################################################################
# Actual program starts here
#

# create thumbnail and website images from the raw images
album = Album.new(options[:metafile], THUMBNAIL_SIZE, S3_BASE_LINK)
album.resize(THUMBNAIL_SIZE)

# upload the photos to S3 if needed
client = S3PhotoClient.new(REGION)
client.sync_album(album)

# update the database with the photos
photo_db = PhotoDb.new(options[:config_file])
photo_db.update_album(album, Album.get_raw_key, THUMBNAIL_SIZE)
