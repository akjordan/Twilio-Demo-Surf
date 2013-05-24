require 'sinatra'

# a hack around multiple routes in Sinatra
def get_or_post(path, opts={}, &block)
  get(path, opts, &block)
  post(path, opts, &block)
end

# setup RestClient caching backed by Memchached
RestClient.enable Rack::Cache,
  :verbose      => true,
  :metastore   => Dalli::Client.new,
  :entitystore => Dalli::Client.new

# base URL for the app
get_or_post '/' do

# an array of San Francisco spot IDs
spot_ids = ["113", "649", "648", "114", "117"]

if params["Body"].include? "spots"

	# query Splitcast API and store JSON of spots
	response = RestClient.get 'http://api.spitcast.com/api/county/spots/san-francisco/', {:accept => :json}
	all_spots = JSON.parse(response)

	# create string called spots to store values from JSON
	spots = String.new

	# iterate over all_spots and pull out spot_name and spot_id
	all_spots.each { |i| spots << "#{i["spot_name"]}: #{i["spot_id"]} " }

	# build Twilio response
	response = Twilio::TwiML::Response.new { |r| r.Sms "#{spots}" }

elsif spot_ids.include? params["Body"]

	# query Splitcast API and store JSON of conditions for a given spot
	response = RestClient.get "http://api.spitcast.com/api/spot/forecast/#{params["Body"]}/", {:accept => :json}
	all_conditions = JSON.parse(response)

	# create string called conditions to store values from JSON
	conditions = String.new

	# iterate over all_conditions and pull out hour, shape_full, and size
	# parse "gmt" from JSON, parse it into a DateTime and compare it to the system time represented in GMT to get only the nearest 4 predictions
	all_conditions.each do |i|
	  time_difference = (DateTime.parse(i["gmt"]).to_time.to_i - (Time.now.getgm.to_i))
	  if (time_difference >= 0 && time_difference <= 14400)
	    conditions << "#{i["hour"]} #{i["size"]}ft shape: #{i["shape_full"]} "
	  end
	end

	# build Twilio response
	response = Twilio::TwiML::Response.new do |r|
	  r.Sms "The conditions at #{all_conditions.first["spot_name"]} will be: #{conditions}"
	end	

else
	
	# build Twilio response
	response = Twilio::TwiML::Response.new do |r|
	  r.Sms "Sorry brah, locals only, please type 'spots' or a valid spot ID"
	end	

end

response.text

end