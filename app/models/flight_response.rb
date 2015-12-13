require 'qpx/qpx_response'

class FlightResponse < ActiveRecord::Base
  belongs_to :flight_request

  before_validation :process_response

  attr_writer :full_response, :response

  def get_response
    @response ||= QpxResponse.from_string(self.date, ActiveSupport::Gzip.decompress(self.response_gz))
  end

  def get_full_response
    @full_response ||= ActiveSupport::Gzip.decompress(self.full_response_gz)
  end

  private
  def process_response
    self.full_response_gz = ActiveSupport::Gzip.compress(@full_response)
    self.response_gz      = ActiveSupport::Gzip.compress(@response.to_json)
  end
end
