class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.belongs_to :album, :index => true, :null => false
      t.string :key, :null => false
      t.string :original, :null => false
      t.string :thumbnail, :null => false
      t.datetime :date, :null => false
    end

    add_index :photos, [:album_id, :key], :unique => true
  end
end
