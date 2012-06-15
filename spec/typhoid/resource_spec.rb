require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Typhoid::Resource do

	it "should have fields defined" do
		game = Game.new
		game.should respond_to(:team_1_name)
	end

	it "should populate fields" do
		response_data = {"team_1_name" => 'Bears', "team_2_name" => 'Lions'}
		game = Game.new(response_data)
		game.team_1_name.should eql 'Bears'
		game.start_time.should be_nil
	end

	it "should return the request path" do
		game = Game.new
		game.request_uri.should eql "http://localhost:3000/games/"
	end

	context "making a standalone request" do

		before(:each) do
			@hydra = Typhoeus::Hydra.hydra
			@game_response = Typhoeus::Response.new(:code => 200, :headers => "", :body => {"team_1_name" => "Bears", "id" => "1"}.to_json)
		end

		it "should retrieve an object" do
		
			@hydra.stub(:get, "http://localhost:3000/games/1").and_return(@game_response)

			game = Game.fetch(Game.get_game)
			game.class.should eql Game
			game.team_1_name.should eql 'Bears'

		end

		it "should create an object" do
			@hydra.stub(:post, "http://localhost:3000/games/").and_return(@game_response)

			game = Game.new
			game.save!

			game.id.should eql "1"
			game.team_1_name.should eql "Bears"
		end
	end

	context "handling bad requests" do
			before(:each) do
				@fake_hydra = Typhoeus::Hydra.new
				bad_game = Typhoeus::Response.new(:code => 500, :headers => "")
				@fake_hydra.stub(:get, "http://localhost:3000/games/1").and_return(bad_game)
			end

			it "should assign an exception object on a bad request" do
				controller = Controller.new
				controller.remote_resources(@fake_hydra) do |req|
					req.resource(:game, Game.get_game)
				end

				bad_game = controller.instance_variable_get("@game")
				bad_game.team_1_name.should be_nil
				bad_game.resource_exception.class.should be_true 
			end
		end


end

