class AddIndexToFlightDataDate < ActiveRecord::Migration
  def change
    add_index :flight_data, :date
  end
end
