#!/usr/bin/env ruby

require 'pathname'
require 'optparse'

require_relative 'lib_photo_update/s3_photo_client'
require_relative 'lib_photo_update/album'
require_relative 'lib_photo_update/photo_db'

class PhotosOptionsParser
  def self.parse(args)
    options    = {}
    opt_parser = OptionParser.new { |opts|
      opts.banner = "Usage #{File.basename($0)} [options]"

      opts.on('-c', '--config=CONFIG', 'JSON configuration file') do |config_file|
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
# Open and parse JSON configuration file
#
config = options[:config_file]
unless File.exist?(config)
  raise IOError, "File #{config} not found"
end

json          = Crack::JSON.parse(File.read(options[:config_file]))

########################################################################################################################
# Actual program starts here
#
thumbnail_dim = json['thumbnail_dim']
region        = json['region']
s3_end_point  = region.equal?('us-east-1') ? 'https://s3.amazonaws.com' : "https://s3-#{region}.amazonaws.com"

# create thumbnail and website images from the raw images
album         = Album.new(options[:metafile], thumbnail_dim, s3_end_point)
album.resize(thumbnail_dim)

# upload the photos to S3 if needed
client = S3PhotoClient.new(region)
client.sync_album(album)

# update the database with the photos
mysql_cfg = json['mysql']
photo_db  = PhotoDb.new(mysql_cfg['host'], mysql_cfg['user'], mysql_cfg['password'])
photo_db.update_album(album, Album.get_raw_key, thumbnail_dim)
