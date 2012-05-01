require 'ngin_http'

class Game
  include NginHttp::Resource

  field :team_1_name
  field :team_2_name
  field :start_time

  def self.get_game
  	build_request("http://localhost:3000/games/1")
  end

end