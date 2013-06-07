require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'json'


describe Typhoid::Multi do
  context "making multiple requests" do
    def typhoeus_stub(verb, url, response, hydra)
      version = Typhoeus::VERSION.to_s.match /(?<major>\d+)\.(?<minor>\d+)\.(?<bug>\d+)/
      if version[:minor].to_i >= 6
        Typhoeus.stub(url).and_return response
      else
        hydra.stub(verb, url).and_return(response)
      end
    end

    before do
      @fake_hydra = Typhoeus::Hydra.new
      game = Typhoid::Response.new(:code => 200, :headers => "", :body => {"team_1_name" => "Bears"}.to_json, :time => 0.03)
      typhoeus_stub :get, "http://localhost:3000/games/1", game, @fake_hydra

      stats = Typhoid::Response.new(:code => 200, :headers => "",
                                    :body => [{'player_name' => 'Bob', 'goals' => 1}, {'player_name' => 'Mike', 'goals' => 1}].to_json, :time => 0.02)
      typhoeus_stub :get, "http://localhost:3000/stats/2", stats, @fake_hydra
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

      #stats returns an array
      controller.instance_variable_get("@stats").class.should eql Array
      controller.instance_variable_get("@stats")[0].class.should eql PlayerStat
      controller.instance_variable_get("@stats")[0].player_name.should eql 'Bob'
    end
  end
end
