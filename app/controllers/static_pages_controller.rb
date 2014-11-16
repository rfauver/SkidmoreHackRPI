class StaticPagesController < ApplicationController
  def home
    if (!cookies[:lat_lng].nil?)
      @lat_lng = cookies[:lat_lng].split("|")
    end
  end

  def new
  end
end
