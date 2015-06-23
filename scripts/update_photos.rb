#!/usr/bin/env ruby
require 'crack'
require 'json'
require 'mysql2'              # mysql2 currently does not support prepared statements but will in version 0.4.0
require 'pathname'
require 'optparse'

class PhotoUpdater
  METADATA_FILE_NAME = 'metadata'
  ALBUM_TABLE = 'albums'
  PHOTO_TABLE = 'photos'
  IMAGES_PATH = '/var/www/rails_website/app/assets/images/'
  DB_NAME = 'website_dev'

  def initialize(mysql_config)
    unless File.exist?(mysql_config)
      raise IOError, "File #{mysql_config} not found"
    end

    File.open(mysql_config) do |file|
      json = Crack::JSON.parse(file.read)
      @host = json['host']
      @user = json['user']
      @password = json['password']
    end

    # password can be nil if there is no password for that user, which is definitely not a good idea, but feasible
    if @host.nil? || @user.nil?
      raise 'Host or user is not defined in the mysql configuration file'
    end
  end

  def update_albums(dir_name)
    album_info = read_metadata(dir_name)
    db = get_db
    begin
      # create album
      album_stmt = create_insert_or_update_stmt(ALBUM_TABLE, %w(key), %w(title cover date),
                                                [album_info.key, album_info.title, album_info.cover, album_info.date])
      db.query(album_stmt)
      puts "Created or updated album: #{album_info.key}"

      album_id = nil
      # create photos
      db.query("SELECT id FROM #{ALBUM_TABLE} WHERE `key`=\"#{album_info.key}\"").each { |row|
        album_id = row['id']
      }

      album_info.photos.each { |photo|
        photo_stmt = create_insert_or_update_stmt(PHOTO_TABLE, ['album_id', 'key'], ['original', 'thumbnail', 'date'],
                                                  [album_id, photo.base_file, photo.orig_file, photo.thumb_file, photo.datetime])
        db.query(photo_stmt)
        puts "Created or updated photo: #{photo.base_file}"
      }
    rescue
      db.close
    end
  end

  private

  def get_db
    @db ||= open_db
  end

  def open_db
    db = Mysql2::Client.new(:host => @host, :username => @user, :password => @password, :database => DB_NAME)
    if db.nil?
      raise 'Unable to open database'
    end
    db
  end

  def read_metadata(dir_name)
    album_info = nil
    File.open(File.join(dir_name, METADATA_FILE_NAME)) do |metadata_file|
      metadata = Crack::JSON.parse(metadata_file.read)
      album_info = AlbumInfo.new(metadata)
    end
    album_info
  end

  def create_insert_or_update_stmt(table, primary_keys, columns, vars)
    update_cols = columns.dup
    if primary_keys.nil?
      insert_cols = columns.dup
    else
      insert_cols = primary_keys
      insert_cols.push(*columns)
    end

    sql_escape = lambda { |x| "`#{x}`" }
    insert_cols.map! &sql_escape
    update_cols.map! { |x| escaped_x = sql_escape[x]; "#{escaped_x}=VALUES(#{escaped_x})" }
    args = "#{insert_cols.map { '?' }.join(',')}"

    stmt = "INSERT INTO #{table} (#{insert_cols.join(',')}) VALUES (#{args}) ON DUPLICATE KEY UPDATE #{update_cols.join(',')}"
    vars.each { |var|
      stmt.sub!(/\?/, "'#{var}'")
    }
    stmt
  end

  class AlbumInfo
    attr_reader :key, :title, :cover, :date, :orig_dir, :thumb_dir, :photos

    def initialize(metadata)
      @key = metadata['key']
      @title = metadata['title']
      @cover = metadata['cover']
      @date = metadata['date']
      @orig_dir = metadata['original_dir']
      @thumb_dir = metadata['thumbnail_dir']
      @photos = read_photos
    end

    class PhotoInfo
      def initialize(base_file, orig_file, thumb_file, datetime)
        @base_file = base_file
        @orig_file = orig_file
        @thumb_file = thumb_file
        @datetime = datetime
      end

      attr_reader :base_file, :orig_file, :thumb_file, :datetime
    end

    private

    def read_photos()
      photos = []
      Dir.glob("#{IMAGES_PATH}/#{@orig_dir}/*") do |full_filename|

        file_basename = File.basename(full_filename)
        thumbnail_filename = Pathname.new("#{@thumb_dir}/#{file_basename}").cleanpath.to_s
        original_filename = Pathname.new("#{@orig_dir}/#{file_basename}").cleanpath.to_s
        datetime = %x(exiftool -CreateDate #{full_filename} -d "%Y-%m-%d %H:%M:%S" | awk '{printf("%s %s", $4, $5)}')

        photos <<= PhotoInfo.new(file_basename, original_filename, thumbnail_filename, datetime)
      end
      photos
    end
  end
end

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage #{$0} [options]"

  opts.on('-c', '--mysql_config=CONFIG' 'MySQL configuration file') do |config_file|
    options[:config_file] = config_file
  end

  opts.on('-d', '--dir=DIR', 'Directory containing the metadata file') do |dir|
    options[:dir] = dir
  end

  opts.on('-h', '--help', 'Show the help message') do
    puts opts
    exit
  end
end.parse!

if options[:dir].nil? || options[:config_file].nil?
  raise OptionParser::MissingArgument, 'Missing directory or configuration argument'
end

photo_updater = PhotoUpdater.new(options[:config_file])
photo_updater.update_albums(options[:dir])
