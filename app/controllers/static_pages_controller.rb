class StaticPagesController < ApplicationController
  def home
    @lat_lng = cookies[:lat_lng].split("|")
  end

  def new
  end
end
