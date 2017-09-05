require 'rest-client'
require 'json'

module MartaBus
  #curl -s  | jq '.[] | select(.DIRECTION == "Southbound").TRIPID' | sed "s/^\"/select trip_id, stop_name from stop_times join stops using (stop_id) where trip_id = '/" | sed "s/\"$/' order by stop_sequence desc limit 1;/" | psql marta | sed -n "3~5p"
  API_URL = "http://developer.itsmarta.com/BRDRestService/BRDRestService.svc/GetBusByRoute/6"

  def self.make_message
    json_resp = RestClient.get(API_URL)
    resp = JSON.load(json_resp)
    southbound_buses = resp.select{|bus| bus["DIRECTION"] == "Southbound" }
    southbound_buses.each do |bus| 
      bus["endpoint"] = `psql -qtA marta -c "select stop_name from stop_times join stops using (stop_id) where trip_id = '#{bus["TRIPID"]}' order by stop_sequence desc limit 1;"`
    end
    message =  (southbound_buses.map do |bus|
      lateness = bus["ADHERENCE"] == "0" ? "on time" : (bus['ADHERENCE'].to_i < 0 ? "#{bus["ADHERENCE"]} min early" : "#{bus["ADHERENCE"]} min late")
      endpoint = bus["endpoint"].strip.size > 0 ? "#{bus["endpoint"].strip}" : "unknown endpoint"
      "Veh ##{bus["VEHICLE"]} to #{endpoint}."
    end.join("\n"))

  end
end

if __FILE__ == $0
  puts MartaBus.make_message
end