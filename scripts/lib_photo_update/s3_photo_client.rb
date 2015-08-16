require 'json'
require 'aws-sdk'

class S3PhotoClient
  def initialize(region)
    Aws.config.update({
                          region: region
                      })
    @s3_client = Aws::S3::Client.new
  end

  def sync_album(album)
    s3_album = create_album(album.metadata.key)
    album.photos.each { |photo|
      photo.images.values.each { |image|
        if not s3_album.contains(image.key)
          upload_image(album.metadata.key, image)
          Logger.log(self, "Uploaded image: #{image.key}")
        else
          Logger.log(self, "Not uploading because already exists #{image.key}")
        end
      }
    }
  end

  private

  # creates if needed
  def create_album(album_key)
    begin
      @s3_client.head_bucket({
                                 bucket: album_key
                             })
    rescue Aws::S3::Errors::NotFound
      Logger.log(self, "Creating bucket: #{album_key}")
      @s3_client.create_bucket({
                                   acl:    'public-read',
                                   bucket: album_key,
                               })
    end

    get_album(album_key)
  end

  def get_album(album_key)
    objects = []
    marker  = nil
    loop do
      resp   = @s3_client.list_objects({
                                           bucket: album_key,
                                           marker: marker
                                       })
      marker = resp.next_marker
      objects.push(*resp.contents)
      break if marker.nil?
    end

    S3Album.new(album_key, objects)
  end

  def upload_image(album_key, image)
    File.open(image.filename, 'rb') { |file|
      resp = @s3_client.put_object(bucket:        album_key,
                                   key:           image.key,
                                   acl:           'public-read',
                                   storage_class: 'REDUCED_REDUNDANCY',
                                   content_type:  'image/jpeg',
                                   body:          file)
      Logger.log(self, "Submitted #{image.key} with version #{resp.version_id} and etag #{resp.etag}")
    }
  end

  class S3Album
    attr_reader :key, :photo_bucket_objs

    def initialize(key, photo_bucket_objs)
      @key               = key
      @photo_bucket_objs = photo_bucket_objs
    end

    def contains(photo_name)
      @photo_bucket_objs.each { |photo_obj|
        return true if photo_name.eql?(photo_obj.key)
      }
      false
    end
  end
end

