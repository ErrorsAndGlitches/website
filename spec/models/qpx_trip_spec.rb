require 'rails_helper'
require 'rails/configuration'

def create_trip(num_round_trips)
  builder             = QpxTripBuilder.new
  builder.adult_count = 1
  builder.thumbnail   = 'thumbnail.jpg'
  (1..num_round_trips).each { |i|
    builder.add_round_trip('SEA', 'ICN', '2012-12-01', "2012-12-#{sprintf('%02d', i)}")
  }
  builder.build
end

def test_trip_save(qpx_trip, num_trips)
  trip_one, flight_requests_one = qpx_trip.save
  trip_two, flight_requests_two = qpx_trip.save

  expect(trip_one).to eq trip_two
  expect(flight_requests_one.size).to eq num_trips
  expect(flight_requests_two.size).to eq num_trips

  flight_requests_one.zip(flight_requests_two).each { |one, two|
    expect(one).to eq two
  }

  all_trips = Trip.all
  expect(all_trips.size).to eq 1
  flight_requests_one.each { |request|
    expect(FlightRequest.find(request.id)).to eq request
  }

  json_qpx_trip_requests = qpx_trip.qpx_requests.inject([]) { |json_reqs, req| json_reqs << req.to_json }
  all_trips.first.flight_requests.inject([]) { |json_qpx_requests, flight_request|
    json_qpx_requests << flight_request.get_request.to_json
  }.each { |json_qpx_request|
    expect(json_qpx_trip_requests.include?(json_qpx_request)).to eq true
  }
end

RSpec.describe QpxTrip, '#save' do
  context 'using a single trip' do
    it 'should save to the DB with only a single QpxRequest' do
      num_trips = 1
      test_trip_save(create_trip(num_trips), num_trips)
    end
  end

  context 'using two trips' do
    it 'should save to the DB with only a single QpxRequest' do
      num_trips = 2
      test_trip_save(create_trip(num_trips), num_trips)
    end
  end
end