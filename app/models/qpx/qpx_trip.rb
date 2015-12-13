require 'qpx/qpx_request'

class QpxTrip

  attr_reader :qpx_requests, :thumbnail

  def initialize(thumbnail, requests)
    @qpx_requests = requests.inject([]) { |qpx_requests, request|
      qpx_requests << QpxRequest.new(request)
    }
    @thumbnail    = thumbnail
  end

  def get_sources
    @qpx_requests.inject([]) { |sources, request|
      sources <<= request.slice.first.origin
    }
  end

  def get_destinations
    @qpx_requests.inject([]) { |sources, request|
      sources <<= request.slice.first.destination
    }
  end

  def get_key
    XXhash.xxh64(@qpx_requests.inject('') { |memo, qpx_req|
      memo += qpx_req.get_key.to_s
    })
  end

  def save
    trip_key = get_key
    trip     = Trip.where(key: trip_key).first_or_create { |trip|
      trip.key       = trip_key
      trip.thumbnail = thumbnail
    }

    flight_requests = @qpx_requests.inject([]) { |requests, qpx_req|
      requests << qpx_req.save
    }

    flight_requests.each { |request|
      FlightRequestGroup.where(trip_id: trip.id).where(flight_request_id: request.id).first_or_create { |frg|
        frg.trip_id           = trip.id
        frg.flight_request_id = request.id
      }
    }

    flight_requests
  end
end