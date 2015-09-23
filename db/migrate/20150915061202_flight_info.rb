class FlightInfo < ActiveRecord::Migration
  def change

    create_table :airports do |t|
      t.string :acronym, :null => false
      t.string :full_name, :null => false
    end

    add_index :airports, :acronym, unique: true

    create_table :flight_queries do |t|
      t.string :source_city, :null => false
      t.string :destination_city, :null => false
      t.date :departure_date, :null => false
      t.date :return_date, :null => false
      t.string :thumbnail, :null => false
      t.string :key, :null => false
    end

    # the key is created inside the FlightQuery model, which is a composition of the cities and dates
    add_index :flight_queries, :key, :unique => true

    create_table :flight_endpoints do |t|
      t.belongs_to :flight_query, :null => false, :index => true
      t.belongs_to :airport, :null => false, :index => true
      t.integer :endpoint_type, :null => false, :limit => 1
    end

    create_table :flight_data do |t|
      t.belongs_to :flight_query, :null => false, :index => true
      t.datetime :date, :null => false
      t.integer :rank, :null => false, :index => true
      t.decimal :cost, :null => false, :precision => 7, :scale => 2
      t.string :carrier, :null => false
      t.string :legs, :null => false
    end

    add_index :flight_data, [:flight_query_id, :date, :rank], unique: true

  end
end
