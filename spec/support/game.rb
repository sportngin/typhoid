require 'typhoid'

class Game < Typhoid::Resource

  field :id
  field :team_1_name
  field :team_2_name
  field :start_time

  self.site = 'http://localhost:3000/'
  self.path = 'games/'

  def self.get_game
  	build_request("http://localhost:3000/games/1")
  end

end