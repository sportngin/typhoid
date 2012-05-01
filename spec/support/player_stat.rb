require 'ngin_http'

class PlayerStat
	include NginHttp::Resource

	field :player_name
	field :goals

	 def self.get_stats
  	build_request("http://localhost:3000/stats/2")
  end

end