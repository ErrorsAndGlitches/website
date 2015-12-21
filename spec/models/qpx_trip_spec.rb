require 'rails_helper'
require 'rails/configuration'

def test_trip_save(trip_save_one, trip_save_two, size)
  trip_one, qpx_requests_one = trip_save_one
  trip_two, qpx_requests_two = trip_save_two

  expect(trip_one).to eq trip_two
  expect(qpx_requests_one.size).to eq size
  expect(qpx_requests_two.size).to eq size

  qpx_requests_one.zip(qpx_requests_two).each { |one, two|
    expect(one).to eq two
  }
end

def create_trip(num_round_trips)
  builder             = QpxTripBuilder.new
  builder.adult_count = 1
  builder.thumbnail   = 'thumbnail.jpg'
  (1..num_round_trips).each { |i|
    builder.add_round_trip('SEA', 'ICN', '2012-12-01', "2012-12-#{sprintf('%02d', i)}")
  }
  builder.build
end

RSpec.describe QpxTrip, '#save' do
  context 'using a single trip' do
    it 'should save to the DB with only a single QpxRequest' do
      num_trips = 1
      qpx_trip = create_trip(num_trips)
      test_trip_save(qpx_trip.save, qpx_trip.save, num_trips)
    end
  end

  context 'using two trips' do
    it 'should save to the DB with only a single QpxRequest' do
      num_trips = 2
      qpx_trip = create_trip(num_trips)
      test_trip_save(qpx_trip.save, qpx_trip.save, num_trips)
    end
  end
end