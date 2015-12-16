class Trip < ActiveRecord::Base
  has_many :flight_request_groups
  has_many :flight_requests, through: :flight_request_groups
  has_many :flight_responses, through: :flight_requests

  def get_sources
    self.flight_requests.inject(Set.new) { |sources, request|
      sources << request.get_request.get_source
    }.to_a.sort!.join(',')
  end

  def get_destinations
    self.flight_requests.inject(Set.new) { |destinations, request|
      destinations << request.get_request.get_destination
    }.to_a.sort!.join(',')
  end

  def get_departure_date
    self.flight_requests.first.get_request.get_departure_date
  end

  def get_return_date
    self.flight_requests.first.get_request.get_return_date || 'N/A'
  end
end
