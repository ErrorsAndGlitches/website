require 'active_support/gzip'
require 'xxhash'

class FlightRequest < ActiveRecord::Base
  has_many :flight_responses, dependent: :destroy

  before_validation :process_request
  validates :key, :request_gz, presence: true

  attr_writer :raw_request

  def get_request
    @raw_request ||= ActiveSupport::Gzip.decompress(@request_gz)
  end

  def self.get_key(raw_request)
    XXhash.xxh64(raw_request)
  end

  def info
    puts key
    puts Base64.encode64(request_gz)
  end

  private
  def process_request
    self.key        = FlightRequest.get_key(@raw_request)
    self.request_gz = ActiveSupport::Gzip.compress(@raw_request)
  end
end
