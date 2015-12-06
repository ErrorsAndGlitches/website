class FlightResponse < ActiveRecord::Base
  belongs_to :flight_request

  before_validation :process_response

  attr_writer :full_response, :response

  def get_response
    @response ||= ActiveSupport::Gzip.decompress(@response_gz)
  end

  private
  def process_response
    self.full_response_gz = ActiveSupport::Gzip.compress(@full_response)
    self.response_gz      = ActiveSupport::Gzip.compress(@response)
  end
end
