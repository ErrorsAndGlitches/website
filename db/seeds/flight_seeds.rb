puts 'Populating DB with flight information'

#
# CREATE AIRPORTS
#
source = Airport.where(:acronym => 'SEA').first_or_create { |src|
  src.acronym   = 'SEA'
  src.full_name = 'Seattle Tacoma International'
}

destination      = Airport.where(:acronym => 'SNA').first_or_create { |src|
  src.acronym   = 'SNA'
  src.full_name = 'John Wayne-Orange County'
}

#
# CREATE FLIGHT QUERY
#
sea_to_sna_query = FlightQuery.new(
  :source_city      => 'Seattle',
  :destination_city => 'Orange County',
  :departure_date   => '01-01-2000',
  :return_date      => '02-01-2000',
  :thumbnail        => 'foobar.png',
)

begin
  sea_to_sna_query.save
rescue ActiveRecord::RecordNotUnique
  puts 'Record not unique'
  sea_to_sna_query = FlightQuery.find_by(key:              sea_to_sna_query.get_flight_key,
                                         source_city:      sea_to_sna_query.source_city,
                                         destination_city: sea_to_sna_query.destination_city,
                                         departure_date:   sea_to_sna_query.departure_date,
                                         return_date:      sea_to_sna_query.return_date)
end

#
# CREATE FLIGHT ENDPOINTS
#
src_endpt = FlightEndpoint.where(endpoint_type: 0, flight_query_id: sea_to_sna_query.id, airport_id: source.id).first_or_create { |endpt|
  endpt.endpoint_type   = 0
  endpt.flight_query_id = sea_to_sna_query.id
  endpt.airport_id      = source.id
}

dest_endpt = FlightEndpoint.where(endpoint_type: 1, flight_query_id: sea_to_sna_query.id, airport_id: destination.id).first_or_create { |endpt|
  endpt.endpoint_type   = 1
  endpt.flight_query_id = sea_to_sna_query.id
  endpt.airport_id      = destination.id
}

#
# CREATE FLIGHT DATA
#
(1..10).each { |i|
  begin
    FlightDatum.create(flight_query_id: sea_to_sna_query.id,
                       date:            '%02d-01-2015' % i,
                       cost:            i * 95,
                       carrier:         'Korean Air',
                       legs:            '[[SEA,INC],[INC,SNA],[SNA,INC],[INC,SEA]]',
                       rank:            1 + (i % 4))
  rescue ActiveRecord::RecordNotUnique
    # ignored
  end
}
