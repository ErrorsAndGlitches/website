require 'test/unit'

require_relative '../qpx/qpx_request'
require_relative 'test_helper'

class QpxRequestTests <Test::Unit::TestCase
  include TestHelper

  def test_builder_defaults
    builder = QpxRequest::Builder.new
    assert_equal(QpxRequest::Builder::DEFAULT_MAX_STOPS, builder.max_stops)
    assert_equal(QpxRequest::Builder::DEFAULT_MAX_CONN_DURATION, builder.max_connection_duration)
    assert_equal(0, builder.adult_count)
    assert_equal(0, builder.child_count)
    assert_equal(0, builder.infant_in_lap_count)
    assert_equal(0, builder.infant_in_seat_count)
    assert_equal(0, builder.senior_count)
    assert_equal(0, builder.max_price)
    assert_equal(0, builder.num_solutions)
    assert_empty(builder.trips)
    assert_equal(QpxRequest::CabinType::COACH, builder.preferred_cabin)
    assert_equal(QpxRequest::SaleCountry::US, builder.sale_country)

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

    builder.build.each { |request|
      assert_equal(expected, request)
    }
  end

  def test_round_trip
    builder               = QpxRequest::Builder.new
    builder.adult_count   = 1
    builder.max_price     = 500
    builder.num_solutions = 70
    builder.add_round_trip('SEA', 'ICN', '2012-12-12', '2012-12-25')

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

    builder.build.each { |request|
      assert_equal(expected, request)
    }
  end

  def test_one_way
    builder = QpxRequest::Builder.new
    builder.add_trip('ICN', 'SEA', '2012-12-25')
    builder.add_trip('SEA', 'ICN', '2012-12-12')

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
    builder.build.each { |request|
      assert_equal(expected[index], request)
      index += 1
    }
  end
end