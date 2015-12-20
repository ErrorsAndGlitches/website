require 'json'
require 'mysql2' # mysql2 currently does not support prepared statements but will in version 0.4.0

require 'assets/util/logger'

class PhotoDb
  DB_NAME     = 'website_dev'
  ALBUM_TABLE = 'albums'
  PHOTO_TABLE = 'photos'

  def initialize(host, user, password)
    @host     = host
    @user     = user
    @password = password

    # password can be nil if there is no password for that user, which is definitely not a good idea, but feasible
    if @host.nil? || @user.nil?
      raise 'Host or user is not defined in the mysql configuration file'
    end
  end

  def update_album(album, raw_dim, thumbnail_dim)
    db = get_db
    begin
      # create album
      album_stmt = create_insert_or_update_stmt(ALBUM_TABLE, %w(key), %w(title cover date),
                                                [album.metadata.key, album.metadata.title,
                                                 album.get_s3_cover_link, album.metadata.date])
      db.query(album_stmt)
      Logger.log(self, "Created or updated album: #{album.metadata.key}")

      album_id = nil
      # create photos
      db.query("SELECT id FROM #{ALBUM_TABLE} WHERE `key`=\"#{album.metadata.key}\"").each { |row|
        album_id = row['id']
      }

      album.photos.each { |photo|
        raw_s3_link       = photo.images[raw_dim].s3_link
        thumbnail_s3_link = photo.images[thumbnail_dim].s3_link
        photo_stmt        = create_insert_or_update_stmt(PHOTO_TABLE, ['album_id', 'key'], ['raw', 'thumbnail', 'date'],
                                                         [album_id, photo.key, raw_s3_link, thumbnail_s3_link, photo.datetime])
        db.query(photo_stmt)
        Logger.log(self, "PhotoDb: Created or updated photo images for: #{photo.raw_filename}")
      }
    rescue Exception => e
      db.close
      raise Exception("Unable to update album due to #{e}")
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
end