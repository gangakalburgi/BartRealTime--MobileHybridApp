require 'Faraday'
require 'json'

class BartController < ApplicationController
  def home
  	stations
  end

  def stations
  	response = Faraday.get 'http://api.bart.gov/api/stn.aspx?cmd=stns&key=MW9S-E7SL-26DU-VV8V&json=y'
  	body = JSON.parse(response.body)
  	@stations = body['root']['stations']['station'].map do |s|
  		{
  			name: s['name'],
  			abbr: s['abbr']
  		}
  	end.to_json
  end

  # [GET /trips?source=<STN_ABBR>&dest=<STN_ABBR>]
  def trips
  	src = params[:source]
  	dest = params[:dest]
  	response = Faraday.get "http://api.bart.gov/api/sched.aspx?cmd=depart&orig=#{src}&dest=#{dest}&date=now&key=MW9S-E7SL-26DU-VV8V&b=0&a=4&l=1&json=y"
  	body = JSON.parse(response.body)
  	@trips = body['root']['schedule']['request']['trip']
  	render json: @trips
  end

  # [GET /station?source=<STN_ABBR> ]
  def station
    src = params[:source]
		puts "I was called **************************************************"
		url = "http://api.bart.gov/api/stn.aspx?cmd=stninfo&orig=#{src}&key=MW9S-E7SL-26DU-VV8V&json=y"
		puts "url : #{url}"
  	response = Faraday.get url
  	body = JSON.parse(response.body)
		puts "response : #{body}"
  	@station = body['root']['stations']['station']
		render json: @station
	end

	# [GET /latlongs_for_two_stations?source=<STN_ABBR>&dest=<STN_ABBR>]
	def latlongs_for_two_stations
   	src = params[:source]
	 	dest = params[:dest]
		url1 = "http://api.bart.gov/api/stn.aspx?cmd=stninfo&orig=#{src}&key=MW9S-E7SL-26DU-VV8V&json=y"
	 	url2 = "http://api.bart.gov/api/stn.aspx?cmd=stninfo&orig=#{dest}&key=MW9S-E7SL-26DU-VV8V&json=y"
 		response1 = Faraday.get url1
		response2 = Faraday.get url2
 		body_src = JSON.parse(response1.body)
		body_dest = JSON.parse(response2.body)
		lat_src = body_src['root']['stations']['station']['gtfs_latitude']
		long_src = body_src['root']['stations']['station']['gtfs_longitude']
		lat_dest = body_dest['root']['stations']['station']['gtfs_latitude']
		long_dest = body_dest['root']['stations']['station']['gtfs_longitude']

		res = {
				'lat_src' => lat_src,
				'long_src' => long_src,
				'lat_dest' => lat_dest,
				'long_dest' => long_dest,
		}

	render json: res
 end
end
