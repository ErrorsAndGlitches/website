require 'assets/util/logger'

class S3IpAddrUploader
  def initialize(region, bucket_name, file_name)
    @bucket_name = bucket_name
    @file_name   = file_name

    Aws.config.update({
                        region: region
                      })
    @s3_client = Aws::S3::Client.new
  end

  def upload_ip_addr(ip_addr)
    create_bucket_if_needed

    @s3_client.put_object(bucket:        @bucket_name,
                          key:           @file_name,
                          acl:           'private',
                          storage_class: 'REDUCED_REDUNDANCY',
                          content_type:  'text/plain',
                          body:          ip_addr)
  end

  private

  def create_bucket_if_needed
    begin
      @s3_client.head_bucket({
                               bucket: @bucket_name
                             })
    rescue Aws::S3::Errors::NotFound
      Logger.log(self, "Creating bucket: #{@bucket_name}")
      @s3_client.create_bucket({
                                 acl:    'public-read',
                                 bucket: @bucket_name,
                               })
    end
  end
end