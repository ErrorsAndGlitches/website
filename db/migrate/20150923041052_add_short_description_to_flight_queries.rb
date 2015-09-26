class AddShortDescriptionToFlightQueries < ActiveRecord::Migration
  def change
    add_column :flight_queries, :short_description, :string, :null => false
  end
end
