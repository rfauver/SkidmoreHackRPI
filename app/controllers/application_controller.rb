class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  require 'net/http'

  helper_method :trip_advisor_call
  helper_method :ring_search
  helper_method :bing_search

  def trip_advisor_call(longitude, lattitude)
    uri = URI("http://api.tripadvisor.com/api/partner/1.0/map/#{lattitude},#{longitude}?key=7f2d53f6-7bec-4b9a-b778-0695f608ba9c")
    result = Net::HTTP.get(uri)
    json_result = ActiveSupport::JSON.decode(result)
  end

  def ring_search lon, lat, radius
    count = 0
    r = 0
    degrees = 0

    while (degrees < 360)
      tempResult = trip_advisor_call(compute_ring_lon(lon, radius, degrees), compute_ring_lat(lat, radius, degrees))
      if tempResult["data"].nil?
        return "nil and lon: #{compute_ring_lon(lon, radius, degrees)}, and lat: #{compute_ring_lat(lat, radius, degrees)} /n 
                #{tempResult} /n 
                #{degrees}"
      end
      if !tempResult["data"].empty?
        return tempResult["data"].first["location_string"]
      end
      degrees += 40
    end
    return "nothing found"
  end

  def bing_search query
    bing_news = Bing.new("Y2lKZazLoLw0bt4pMSqV8t5Qp3t+7HSoxW60Lw2RbyA", 10, 'News')
    bing_results = bing_news.search(query)
    # return bing_results
    output = ''
    bing_results.first[:News].each do |res_hash|
      output += "<h2><a href='#{res_hash[:Url]}'>#{res_hash[:Title]}</a></h2><br>" 
    end
    output
  end

  def compute_ring_lon lon, radius, degrees
    radius_degrees = radius.to_f / 69
    radians = degrees * Math::PI / 180
    x = radius_degrees * Math.cos(radians)
    lon + x
  end

  def compute_ring_lat lat, radius, degrees
    radius_degrees = radius.to_f / 69
    radians = degrees * Math::PI / 180
    y = radius_degrees * Math.sin(radians)
    lat + y
  end
end
