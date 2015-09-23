require 'digest'

class FlightQuery < ActiveRecord::Base
  has_many :flight_datums, :dependent => :destroy
  has_many :flight_endpoints
  has_many :sources,
           -> { where(flight_endpoints: { endpoint_type: 0 }) },
           :through    => :flight_endpoints,
           :source     => :airport,
           :class_name => 'Airport'
  has_many :destinations,
           -> { where(flight_endpoints: { endpoint_type: 1 }) },
           :through    => :flight_endpoints,
           :source     => :airport,
           :class_name => 'Airport'

  validates :key, presence: true

  before_validation :set_flight_key

  def get_flight_key
    "#{self.source_city}_#{self.destination_city}_#{self.departure_date}_#{self.return_date}"
  end

  private

  def set_flight_key
    self.key = get_flight_key
  end
end
