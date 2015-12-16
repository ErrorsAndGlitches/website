class CreateFlightResponses < ActiveRecord::Migration
  def change
    create_table :flight_responses do |t|
      t.belongs_to :flight_request, :index => true, :null => false
      t.datetime :date, :index => true, :null => false
      t.binary :full_response_gz, :limit => 1.megabyte, :null => false
      t.binary :response_gz, :limit => 5.kilobyte, :null => false
    end
  end
end
