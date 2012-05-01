require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'json'


describe NginHttp::Io do

		context "making multiple requests" do

			before(:each) do
				@fake_hydra = Typhoeus::Hydra.new
				game = Typhoeus::Response.new(:code => 200, :headers => "", :body => {"team_1_name" => "Bears"}.to_json, :time => 0.03)
				@fake_hydra.stub(:get, "http://localhost:3000/games/1").and_return(game)

				stats = Typhoeus::Response.new(:code => 200, :headers => "", 
						:body => [{'player_name' => 'Bob', 'goals' => 1}, {'player_name' => 'Mike', 'goals' => 1}].to_json, :time => 0.02)
				@fake_hydra.stub(:get, "http://localhost:3000/stats/2").and_return(stats)
			end

			it "should assign the response to instance variables" do
				controller = Controller.new
				controller.remote_resources(@fake_hydra) do |req|
					req.resource(:game, Game.get_game)
					req.resource(:stats, PlayerStat.get_stats)
				end
				#games returns a single object
				controller.instance_variable_get("@game").class.should eql Game
				controller.instance_variable_get("@game").team_1_name.should eql "Bears"

				#players returns an array
				controller.instance_variable_get("@stats").class.should eql Array
				controller.instance_variable_get("@stats")[0].class.should eql PlayerStat
				controller.instance_variable_get("@stats")[0].player_name.should eql 'Bob'
			end

		end
end