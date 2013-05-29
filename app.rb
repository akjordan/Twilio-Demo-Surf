require 'sinatra'

# setup RestClient caching backed by Memcachier
RestClient.enable Rack::Cache,
  :verbose      => true,
  :metastore   => Dalli::Client.new,
  :entitystore => Dalli::Client.new

# get request
get "/*" do
	# render web.md into the index tempate using erb
	markdown :web, :layout_engine => :erb, :layout => :index
end

# base URL for the app
post "/" do

# an array of San Francisco spot IDs
spot_ids = ["113", "649", "648", "114", "117"]

incoming_sms = params["Body"].chomp.downcase

if incoming_sms.include?("spots")
	# query Splitcast API and store JSON of spots
	response = RestClient.get("http://api.spitcast.com/api/county/spots/san-francisco/", :accept => :json)
	all_spots = JSON.parse(response)

	# create string called spots to store values from JSON
	spots = ""

	# iterate over all_spots and pull out spot_name and spot_id
	all_spots.each { |i| spots << "#{i["spot_name"]}: #{i["spot_id"]}\n" }

	# build Twilio response
	response = Twilio::TwiML::Response.new { |r| r.Sms "Reply with an ID to get a forecast\n#{spots}" }
elsif spot_ids.include?(incoming_sms)
	# query Splitcast API and store JSON of conditions for a given spot
	response = RestClient.get("http://api.spitcast.com/api/spot/forecast/#{incoming_sms}/", :accept => :json)
	all_conditions = JSON.parse(response)

	# create string called conditions to store values from JSON
	conditions = ""

	# iterate over all_conditions and pull out hour, shape_full, and size
	# parse "gmt" from JSON, parse it into a DateTime and compare it to the system time represented in GMT to get only the nearest 4 predictions
	all_conditions.each do |i|
	  time_difference = (DateTime.parse(i["gmt"]).to_time.to_i - (Time.now.getgm.to_i))
	  if (time_difference >= 0 && time_difference <= 14400)
	    conditions << "#{i["hour"]}: #{i["size_ft"].round(2)}ft, #{i["shape_full"]}\n"
	  end
	end

	# build Twilio response
	response = Twilio::TwiML::Response.new  { |r| r.Sms "Conditions for #{all_conditions.first["spot_name"]}\n* Time: size, shape *\n#{conditions}" }
else
	# build Twilio response
	response = Twilio::TwiML::Response.new  { |r| r.Sms "Sorry brah, locals only, type 'spots' to get a list of spots in SF or the ID of your favorite spot to get conditions for the next 4 hours at that spot." }
end

response.text
end