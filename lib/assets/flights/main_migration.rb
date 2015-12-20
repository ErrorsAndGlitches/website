require 'qpx/qpx_trip_builder'
require 'qpx/qpx_response'

require 'date'
require 'mysql2'

THUMBNAIL    = 'http://www.mapsofworld.com/flags/images/world-flags/Republic-of-korea-flag.jpg'
SOURCES      = %w(ICN GMP)
DESTINATIONS = %w(SEA)
CURRENCY     = 'USD'

CARRIER_NAME_TO_CODE_MAP = {
  :'Korean Air Lines Co. Ltd.'   => 'KE',
  :'Hawaiian Airlines, Inc.'     => 'HA',
  :'Air Canada'                  => 'AC',
  :'Asiana Airlines Inc.'        => 'OZ',
  :'All Nippon Airways Co. Ltd.' => 'NH',
  :'Emirates'                    => 'EK',
  :'United Airlines, Inc.'       => 'UA'
}

AIRPORT_CODE_TO_NAME = {
  :SEA => 'Seattle/Tacoma Sea/Tac',
  :GMP => 'Seoul Gimpo International',
  :HND => 'Tokyo International (Haneda)',
  :NRT => 'Tokyo Narita International',
  :TPE => 'Taipei Taiwan Taoyuan International',
  :TSA => 'Taipei Songshan',
  :ICN => 'Seoul Incheon International',
  :SFO => 'San Francisco International',
  :LAX => 'Los Angeles International',
  :YVR => 'Vancouver International',
  :DXB => 'Dubai International',
  :HNL => 'Honolulu International'
}

def carrier_name_to_acronym(name)
  acronym = CARRIER_NAME_TO_CODE_MAP[name.to_sym]
  raise Exception.new("Could not find carrier acronym for #{name}") if acronym.nil?
  acronym
end

def airport_code_to_name(code)
  name = AIRPORT_CODE_TO_NAME[code.to_sym]
  raise Exception.new("Could not find airport name for #{code}") if name.nil?
  name
end

def get_qpx_trip
  qpx_trip_builder               = QpxTripBuilder.new
  qpx_trip_builder.adult_count   = 1
  qpx_trip_builder.max_price     = 1900
  qpx_trip_builder.num_solutions = 500
  qpx_trip_builder.thumbnail     = THUMBNAIL
  SOURCES.each { |src|
    DESTINATIONS.each { |dst|
      qpx_trip_builder.add_round_trip(src, dst, '2015-07-19', '2015-07-26')
    }
  }

  qpx_trip_builder.build
end

def create_qpx_carrier(name)
  {
    :name => name,
    :code => carrier_name_to_acronym(name)
  }
end

def create_qpx_airport(code)
  {
    :code => code,
    :name => airport_code_to_name(code)
  }
end

def parse_airport_codes_from_string(str)
  codes = Set.new
  str.scan(/[A-Z]{3}/) { |code|
    codes << code
  }
  codes.to_a.sort!
end

def create_qpx_data(row)
  airports = parse_airport_codes_from_string(row['legs']).inject([]) { |aps, code|
    aps << create_qpx_airport(code)
  }

  {
    :airports => airports,
    :carriers => [create_qpx_carrier(row['carrier'])]
  }
end

def create_qpx_segments(carrier_code, segments)
  # (ICN, HNL)
  segments.scan(/\(.+?\)/).inject([]) { |segs, str|
    origin, destination = str.scan(/[A-Z]{3}/)
    leg                 = {
      :origin      => origin,
      :destination => destination
    }

    segs << {
      :carrier => carrier_code,
      :legs    => [leg]
    }
  }
end

def create_qpx_slices(carrier_code, str)
  # [(ICN, HNL), (HNL, SEA)]
  str.scan(/\[.+?\]/).inject([]) { |slices, s|
    slices << {
      :segments => create_qpx_segments(carrier_code, s)
    }
  }
end

def create_qpx_trip_option(row)
  {
    :currency => CURRENCY,
    :price    => row['cost'].to_i,
    :slices   => create_qpx_slices(carrier_name_to_acronym(row['carrier']), row['legs'])
  }
end

def create_response_from_row(row)
  {
    :trips => {
      :data         => create_qpx_data(row),
      :trip_options => [create_qpx_trip_option(row)]
    }
  }
end

def add_trip_to_qpx_response_from_row(qpx_response, row)
  qpx_response[:trips][:trip_options] << create_qpx_trip_option(row)
end

def get_date(row)
  DateTime.parse(row['date'] + '-08:00')
end

def is_icn_flight(row)
  row['legs'].include?('ICN')
end

def put_json(thing)
  puts JSON.pretty_generate(JSON.parse(thing.to_json))
end

def qpx_hash_to_qpx_responses(qpx_hash)
  qpx_hash.map { |date, qpx_resp|
    QpxResponse.new(date, qpx_resp.to_json, Symbolizer.symbolize_hash(qpx_resp[:trips]))
  }
end

client = Mysql2::Client.new(:host => 'localhost', :username => 'mufasa', :password => 'heimdall13!', :database => 'flight_infos')

qpx_trip      = get_qpx_trip
icn_qpx_resp_hash = {}
gmp_qpx_resp_hash = {}

client.query('SELECT * FROM records').each { |row|
  date     = get_date(row)
  qpx_resp_hash = is_icn_flight(row) ? icn_qpx_resp_hash : gmp_qpx_resp_hash

  qpx_resp = qpx_resp_hash[date]
  if qpx_resp.nil?
    qpx_resp_hash[date] = create_response_from_row(row)
  else
    add_trip_to_qpx_response_from_row(qpx_resp, row)
  end
}

icn_qpx_responses = qpx_hash_to_qpx_responses(icn_qpx_resp_hash)
gmp_qpx_responses = qpx_hash_to_qpx_responses(gmp_qpx_resp_hash)

icn_flight_req, gmp_flight_req = qpx_trip.save

icn_qpx_responses.each { |resp|
  resp.save(icn_flight_req)
}

gmp_qpx_responses.each { |resp|
  resp.save(gmp_flight_req)
}
