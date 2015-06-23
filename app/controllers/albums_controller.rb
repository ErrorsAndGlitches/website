class AlbumsController < ApplicationController
  def index
    @selected_tab   = :photos
    @albums         = Album.order(:date)
  end

  def album
    @selected_tab = :photos

    id      = params[:id]
    @album  = Album.find(id)
    @photos = Photo.where(album_id: id).order(:date)
  end

  def show_photo
    @selected_tab = :photos

    album_id = params[:id]
    photo_id = params[:photo]
    @photo = Photo.where(album_id: album_id, id: photo_id).first
  end

end
