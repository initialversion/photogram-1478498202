class PhotosController < ApplicationController
  before_action :current_user_must_be_photo_user, :only => [:edit, :update, :destroy]

  def current_user_must_be_photo_user
    photo = Photo.find(params[:id])

    unless current_user == photo.owner
      redirect_to :back, :alert => "You are not authorized for that."
    end
  end

  def index
    @q = current_user.photos.ransack(params[:q])
      @photos = @q.result(:distinct => true).includes(:owner, :likes, :comments, :fans, :followers, :commenters).page(params[:page]).per(params[:per_page])
    @location_hash = Gmaps4rails.build_markers(@photos.where.not(:location_latitude => nil)) do |photo, marker|
      marker.lat photo.location_latitude
      marker.lng photo.location_longitude
      marker.infowindow "<h5><a href='/photos/#{photo.id}'>#{photo.created_at}</a></h5><small>#{photo.location_formatted_address}</small>"
    end

    render("photos/index.html.erb")
  end

  def show
    @comment = Comment.new
    @vote = Vote.new
    @photo = Photo.find(params[:id])

    render("photos/show.html.erb")
  end

  def new
    @photo = Photo.new

    render("photos/new.html.erb")
  end

  def create
    @photo = Photo.new

    @photo.caption = params[:caption]
    @photo.image = params[:image]
    @photo.location = params[:location]
    @photo.owner_id = params[:owner_id]

    save_status = @photo.save

    if save_status == true
      redirect_to(:back, :notice => "Photo created successfully.")
    else
      render("photos/new.html.erb")
    end
  end

  def edit
    @photo = Photo.find(params[:id])

    render("photos/edit.html.erb")
  end

  def update
    @photo = Photo.find(params[:id])

    @photo.caption = params[:caption]
    @photo.image = params[:image]
    @photo.location = params[:location]
    @photo.owner_id = params[:owner_id]

    save_status = @photo.save

    if save_status == true
      redirect_to(:back, :notice => "Photo updated successfully.")
    else
      render("photos/edit.html.erb")
    end
  end

  def destroy
    @photo = Photo.find(params[:id])

    @photo.destroy

    redirect_to(:back, :notice => "Photo deleted.")
  end
end
