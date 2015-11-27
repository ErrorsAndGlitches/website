require_relative '../qpx/qpx_request'
require 'test/unit'

class QpxRequestTests <Test::Unit::TestCase
  def test_builder_defaults
    builder = QpxRequest::Builder.new
    assert_equal(QpxRequest::Builder::DEFAULT_MAX_STOPS, builder.max_stops)
    assert_equal(QpxRequest::Builder::DEFAULT_MAX_CONN_DURATION, builder.max_connection_duration)
    assert_equal(0, builder.adult_count)
    assert_equal(0, builder.child_count)
    assert_equal(0, builder.infant_in_lap_count)
    assert_equal(0, builder.infant_in_seat_count)
    assert_equal(0, builder.senior_count)
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
        :saleCountry => :US
      }
    }

    assert_equal(expected, builder.build)
  end

  def test_builder_build
    builder             = QpxRequest::Builder.new
    builder.adult_count = 1
    builder.add_trip('SEA', 'ICN', '2012-12-12')
    builder.add_trip('ICN', 'SEA', '2012-12-25')

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
        :saleCountry => :US
      }
    }

    assert_equal(expected, builder.build)
  end
end