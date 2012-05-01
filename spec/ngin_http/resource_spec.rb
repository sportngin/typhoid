require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NginHttp::Resource do

	it "should have fields defined" do
		game = Game.new(nil)
		game.should respond_to(:team_1_name)
	end

	it "should populate fields" do
		response_data = {"team_1_name" => 'Bears', "team_2_name" => 'Lions'}
		game = Game.new(response_data)
		game.team_1_name.should eql 'Bears'
		game.start_time.should be_nil
	end
end

