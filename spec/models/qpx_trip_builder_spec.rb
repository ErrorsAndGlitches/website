require 'rails_helper'
require 'qpx/qpx_trip_builder'

RSpec.describe QpxTripBuilder, '#new' do
  context 'with no builder options set' do
    it 'should contain default request options' do
      builder = QpxTripBuilder.new
      expect(builder.max_stops).to eq QpxTripBuilder::DEFAULT_MAX_STOPS
      expect(builder.max_connection_duration).to eq QpxTripBuilder::DEFAULT_MAX_CONN_DURATION
      expect(builder.adult_count).to eq 0
      expect(builder.child_count).to eq 0
      expect(builder.infant_in_lap_count).to eq 0
      expect(builder.infant_in_seat_count).to eq 0
      expect(builder.senior_count).to eq 0
      expect(builder.max_price).to eq 0
      expect(builder.num_solutions).to eq 0
      expect(builder.trips.size).to eq 0
      expect(builder.preferred_cabin).to eq QpxTripBuilder::CabinType::COACH
      expect(builder.sale_country).to eq QpxTripBuilder::SaleCountry::US
      expect(builder.thumbnail).to eq nil
    end
  end
end

RSpec.describe QpxTripBuilder, '#build' do
  def self.test_yield(qpx_trip, n)
    specify { expect { |b| qpx_trip.qpx_requests.each(&b) }.to yield_control.exactly(n).times }
  end

  context 'using default builder options' do
    qpx_trip = QpxTripBuilder.new.build

    test_yield(qpx_trip, 0)

    it 'should build a request with default options' do
      expected = {
        :request => {
          :passengers  => {
            :kind              => 'qpxexpress#passengerCounts',
            :adultCount        => 0,
            :childCount        => 0,
            :infantInLapCount  => 0,
            :infantInSeatCount => 0,
            :seniorCount       => 0 },
          :slice       => [],
          :saleCountry => :US,
          :maxPrice    => 'USD0',
          :solutions   => 0
        }
      }

      qpx_trip.qpx_requests.each { |request|
        expect(request).to eq expected
      }
    end
  end

  context 'adding one round-trip data for the builder' do
    THUMBNAIL = 'i am a thumbnail'

    builder               = QpxTripBuilder.new
    builder.adult_count   = 1
    builder.max_price     = 500
    builder.num_solutions = 70
    builder.thumbnail     = THUMBNAIL
    builder.add_round_trip('SEA', 'ICN', '2012-12-12', '2012-12-25')
    qpx_trip = builder.build

    test_yield(qpx_trip, 1)

    it 'should create a single round-trip request' do
      expected = {
        :request => {
          :passengers  => {
            :kind              => 'qpxexpress#passengerCounts',
            :adultCount        => 1,
            :childCount        => 0,
            :infantInLapCount  => 0,
            :infantInSeatCount => 0,
            :seniorCount       => 0 },
          :slice       => [
            {
              :kind                  => 'qpxexpress#sliceInput',
              :origin                => 'SEA',
              :destination           => 'ICN',
              :date                  => '2012-12-12',
              :maxStops              => 1,
              :maxConnectionDuration => 600,
              :preferredCabin        => :COACH
            },
            {
              :kind                  => 'qpxexpress#sliceInput',
              :origin                => 'ICN',
              :destination           => 'SEA',
              :date                  => '2012-12-25',
              :maxStops              => 1,
              :maxConnectionDuration => 600,
              :preferredCabin        => :COACH
            }
          ],
          :saleCountry => :US,
          :maxPrice    => 'USD500',
          :solutions   => 70
        }
      }

      qpx_trip.qpx_requests.each { |request|
        expect(request).to eq expected
      }

      expect(qpx_trip.thumbnail).to eq THUMBNAIL
    end
  end

  context 'adding two one-way trips' do
    builder = QpxTripBuilder.new
    builder.add_trip('ICN', 'SEA', '2012-12-25')
    builder.add_trip('SEA', 'ICN', '2012-12-12')
    qpx_trip = builder.build

    test_yield(qpx_trip, 2)

    it 'should create two one-way requests' do
      expected = [
        {
          :request => {
            :passengers  => {
              :kind              => 'qpxexpress#passengerCounts',
              :adultCount        => 0,
              :childCount        => 0,
              :infantInLapCount  => 0,
              :infantInSeatCount => 0,
              :seniorCount       => 0 },
            :slice       => [
              {
                :kind                  => 'qpxexpress#sliceInput',
                :origin                => 'ICN',
                :destination           => 'SEA',
                :date                  => '2012-12-25',
                :maxStops              => 1,
                :maxConnectionDuration => 600,
                :preferredCabin        => :COACH
              }
            ],
            :saleCountry => :US,
            :maxPrice    => 'USD0',
            :solutions   => 0
          }
        },
        {
          :request => {
            :passengers  => {
              :kind              => 'qpxexpress#passengerCounts',
              :adultCount        => 0,
              :childCount        => 0,
              :infantInLapCount  => 0,
              :infantInSeatCount => 0,
              :seniorCount       => 0 },
            :slice       => [
              {
                :kind                  => 'qpxexpress#sliceInput',
                :origin                => 'SEA',
                :destination           => 'ICN',
                :date                  => '2012-12-12',
                :maxStops              => 1,
                :maxConnectionDuration => 600,
                :preferredCabin        => :COACH
              }
            ],
            :saleCountry => :US,
            :maxPrice    => 'USD0',
            :solutions   => 0
          }
        }
      ]

      index = 0
      qpx_trip.qpx_requests.each { |request|
        expect(request).to eq expected[index]
        index += 1
      }
    end
  end
end
