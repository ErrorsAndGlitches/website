class CreateTrips < ActiveRecord::Migration
  def change
    create_table :trips do |t|
      t.string :key, :index => true, :null => false
    end
  end
end
