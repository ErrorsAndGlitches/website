class Album
  attr_reader :metadata, :photos

  def initialize(metadata_filename, cover_dim, s3_end_point)
    @metadata     = AlbumMetadata.new(metadata_filename)
    @cover_dim    = cover_dim
    @s3_end_point = s3_end_point
    @photos       = get_raw_photos
  end

  def resize(dim)
    unless File.exists?(@metadata.resized_dir)
      Dir.mkdir(@metadata.resized_dir)
    end

    @photos.each { |photo|
      filename         = photo.images[Album.get_raw_key].filename
      resized_filename = resize_photo(dim, filename)
      photo.add_dim(dim, resized_filename)
    }
    nil
  end

  def get_s3_cover_link
    PhotoInfo.get_s3_photo_link(@s3_end_point, @metadata.key, Album.get_resized_filename(@cover_dim, @metadata.cover))
  end

  def self.get_raw_key
    :raw
  end

  private

  def get_raw_photos
    raw_photos = []
    Dir.glob("#{@metadata.raw_dir}/*").each { |photo_filename|
      datetime   = %x(exiftool -CreateDate #{photo_filename} -d "%Y-%m-%d %H:%M:%S" | awk '{printf("%s %s", $4, $5)}')
      raw_photos <<= PhotoInfo.new(@metadata.key, photo_filename, datetime, @s3_end_point)
    }
    raw_photos
  end

  def resize_photo(dim, raw_filename)
    resized_filename = File.join(@metadata.resized_dir, Album.get_resized_filename(dim, raw_filename))

    if File.exists?(resized_filename)
      Logger.log(self, "Not creating because already exists #{resized_filename}")
    else
      unless system("gm convert #{raw_filename} -resize #{dim}x#{dim} #{resized_filename}")
        raise Exception.new("Could not create resized image #{resized_filename}")
      end
      Logger.log(self, "Created: #{resized_filename}")
    end

    resized_filename
  end

  def self.get_resized_filename(dim, filename)
    "#{dim}x#{dim}_#{File.basename(filename)}"
  end

  class AlbumMetadata
    attr_reader :key, :title, :cover, :date, :raw_dir, :resized_dir

    def initialize(metadata_filename)
      unless File.exists?(metadata_filename) && File.file?(metadata_filename)
        raise Exception.new("Metadata file is invalid #{metadata_filename}")
      end

      dir_name = File.dirname(metadata_filename)

      File.open(metadata_filename) do |metadata_file|
        metadata     = JSON.parse(metadata_file.read)
        @key         = metadata['key']
        @title       = metadata['title']
        @cover       = metadata['cover']
        @date        = metadata['date']
        @raw_dir     = File.join(dir_name, metadata['raw_dir'])
        @resized_dir = File.join(dir_name, metadata['resized_dir'])
      end
    end
  end

  class PhotoInfo
    attr_reader :raw_filename, :key, :datetime, :images

    def initialize(album_key, raw_filename, datetime, s3_end_point)
      @album_key    = album_key
      @raw_filename = raw_filename
      @key          = File.basename(raw_filename)
      @datetime     = datetime
      @s3_end_point = s3_end_point
      @images       = {}
      add_dim(Album.get_raw_key, @raw_filename)
    end

    def add_dim(dim, filename)
      key          = File.basename(filename)
      @images[dim] = Image.new(filename, key, PhotoInfo.get_s3_photo_link(@s3_end_point, @album_key, key))
    end

    def self.get_s3_photo_link(s3_end_point, album_key, photo_key)
      "#{s3_end_point}/#{album_key}/#{photo_key}"
    end
  end

  class Image
    attr_reader :filename, :key, :s3_link

    def initialize(filename, key, s3_link)
      @filename = filename
      @key      = key
      @s3_link  = s3_link
    end
  end
end