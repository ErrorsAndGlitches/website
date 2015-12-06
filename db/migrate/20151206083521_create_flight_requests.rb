class CreateFlightRequests < ActiveRecord::Migration
  def change
    create_table :flight_requests do |t|
      t.string :key, :index => true, :null => false
      t.binary :request_gz, :limit => 1.kilobytes, :null => false
    end
  end
end
