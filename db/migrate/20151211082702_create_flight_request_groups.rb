class CreateFlightRequestGroups < ActiveRecord::Migration
  def change
    create_table :flight_request_groups do |t|
      t.belongs_to :trip, :index => true, :null => false
      t.belongs_to :flight_request, :index => true, :null => false
    end

    add_foreign_key :flight_request_groups, :trips
    add_foreign_key :flight_request_groups, :flight_requests
  end
end
