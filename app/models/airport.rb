class Airport < ActiveRecord::Base
  has_many :flight_endpoints
end
