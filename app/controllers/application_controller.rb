class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  require 'net/http'

  helper_method :trip_advisor_call
  helper_method :ring_search

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




    # tempResult = trip_advisor_call(lon, lat)
    # while tempResult["data"].empty? 
    #   count += 1
    #   if count %10 == 0 && count != 0
    #     sleep(1.01)
    #   end
    #   if count%4 == 0
    #     r += 1
    #     tempResult = trip_advisor_call(lon + r, lat)
    #   elsif count%4 == 1
    #     tempResult = trip_advisor_call(lon, lat + r)
    #   elsif count%4 == 2
    #     tempResult = trip_advisor_call(lon - r, lat)
    #   else
    #     tempResult = trip_advisor_call(lon, lat - r)
    #   end
    # end
    # if tempResult.nil?
    #   return "not found"
    # end
    # tempResult
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
