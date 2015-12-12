class Trip < ActiveRecord::Base
  has_many :flight_requests, through: :flight_request_groups
end
