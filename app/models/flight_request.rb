require 'active_support/gzip'
require 'xxhash'
require 'qpx/qpx_request'

class FlightRequest < ActiveRecord::Base
  has_many :flight_request_groups
  has_many :flight_responses, dependent: :destroy

  before_validation :process_request
  validates :key, :request_gz, presence: true

  attr_writer :qpx_request

  def get_request
    @qpx_request ||= QpxRequest.from_string(ActiveSupport::Gzip.decompress(self.request_gz))
  end

  def info
    puts key
    puts Base64.encode64(request_gz)
  end

  private
  def process_request
    self.key        = @qpx_request.get_key
    self.request_gz = ActiveSupport::Gzip.compress(@qpx_request.to_json)
  end
end
