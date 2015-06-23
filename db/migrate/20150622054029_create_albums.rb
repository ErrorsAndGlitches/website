class CreateAlbums < ActiveRecord::Migration
  def change
    create_table :albums do |t|
      t.string :key, :null => false
      t.string :title, :null => false
      t.string :cover, :null => false
      t.datetime :date, :null => false
    end

    add_index :albums, :key, :unique => true
  end
end
