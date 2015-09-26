class AddIntervalToFlightQueries < ActiveRecord::Migration
  def change
    add_column :flight_queries, :interval, :integer, :null => false
  end
end
