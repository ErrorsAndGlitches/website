require 'digest'

class FlightQuery < ActiveRecord::Base
  has_many :flight_datums,
           -> { order(date: :asc).order(rank: :asc) },
           :dependent => :delete_all
  has_many :flight_endpoints
  has_many :sources,
           -> { where(flight_endpoints: { endpoint_type: 0 }) },
           :through    => :flight_endpoints,
           :source     => :airport,
           :class_name => 'Airport'
  has_many :destinations,
           -> { where(flight_endpoints: { endpoint_type: 1 }) },
           :through    => :flight_endpoints,
           :source     => :airport,
           :class_name => 'Airport'

  after_initialize :categorize_ranks
  before_validation :set_flight_key
  validates :key, presence: true

  def get_flight_key
    "#{self.source_city}_#{self.destination_city}_#{self.departure_date}_#{self.return_date}"
  end

  def read_flight_dates
    @ordered_flight_datums.each_pair { |query_iteration, ranks|
      yield(iteration_to_date(query_iteration), ranks)
    }
  end

  private

  def set_flight_key
    self.key = get_flight_key
  end

  # the data is queried from the DB in sorted order - just need to split up the data and populate the needed fields
  def categorize_ranks
    if self.flight_datums.nil? || self.flight_datums.empty?
      return
    end

    # find the last rank 1, iterating backwards
    last_r1_datum = nil
    self.flight_datums.reverse_each { |datum|
      if datum.rank == 1
        last_r1_datum = datum
        break
      end
    }

    array_size = get_query_iteration(last_r1_datum) + 1
    max_rank   = FlightDatum.maximum(:rank)

    @ordered_flight_datums = Hash.new
    (0...array_size).each { |iteration|
      @ordered_flight_datums[iteration] = Array.new(max_rank, 'null')
    }

    self.flight_datums.each { |flight_datum|
      @ordered_flight_datums[get_query_iteration(flight_datum)][flight_datum.rank - 1] = flight_datum
    }
  end

  def get_query_iteration(flight_datum)
    (secs_to_hrs(flight_datum.date.to_i) - secs_to_hrs(self.flight_datums.first.date.to_i)) / self.interval
  end

  def iteration_to_date(iteration)
    self.flight_datums.first.date + self.interval * iteration * 3600
  end

  def secs_to_hrs(sec)
    sec / 3600
  end
end
