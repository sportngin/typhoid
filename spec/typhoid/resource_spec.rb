require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Typhoid::Resource do
  def new_typhoeus?
    Typhoid.typhoeus.major_version == 0 && Typhoid.typhoeus.minor_version >= 6
  end

  def typhoeus_stub(verb, url, response, hydra)
    if new_typhoeus?
      Typhoeus.stub(url).and_return response
    else
      hydra.stub(verb, url).and_return(response)
    end
  end

  it "synchronizes field with attribute" do
    response_data = {"team_1_name" => 'Bears', "team_2_name" => 'Lions'}
    game = Game.new(response_data)
    game.team_1_name.should == 'Bears'
    game.attributes["team_1_name"].should == 'Bears'
    game.attributes["team_1_name"] = 'Da Bears'
    game.attributes["team_1_name"].should == 'Da Bears'
    game.team_1_name.should == 'Da Bears'

    game.team_1_name = 'Orange'
    game.team_1_name.should == 'Orange'
    game.attributes["team_1_name"].should == 'Orange'
  end

  it "should have fields defined" do
    game = Game.new
    game.should respond_to(:team_1_name)
  end

  it "should populate defined attributes" do
    response_data = {"team_1_name" => 'Bears', "team_2_name" => 'Lions'}
    game = Game.new(response_data)
    game.team_1_name.should == 'Bears'
    game.start_time.should be_nil
  end

  it "should populate attributes" do
    game = Game.new({"team_1_name" => 'Bears', "team_2_name" => 'Lions'})
    game.read_attribute(:team_1_name).should == 'Bears'
    game[:team_2_name].should == 'Lions'
  end

  it "should return the request path" do
    game = Game.new
    game.request_uri.should == "http://localhost:3000/games"
  end

  context "making a standalone request" do
    let(:hydra) { Typhoeus::Hydra.hydra }
    let(:game_response) { Typhoeus::Response.new(:code => 200, :headers => "", :body => {"team_1_name" => "Bears", "id" => "1"}.to_json) }
    let(:failed_game_response) { Typhoeus::Response.new(:code => 404, :headers => "", :body => {}.to_json) }

    before do
      hydra.clear_stubs unless new_typhoeus?
    end

    it "should retrieve an object" do
      typhoeus_stub(:get, "http://localhost:3000/games/1", game_response, hydra)

      game = Game.get_game.run
      game.class.should == Game
      game.team_1_name.should == 'Bears'
    end

    it "raises error on save!" do
      typhoeus_stub(:post, "http://localhost:3000/games", failed_game_response, hydra)

      game = Game.new
      expect { game.save! }.to raise_error
    end

    it "raises error on destroy!" do
      typhoeus_stub(:delete, "http://localhost:3000/games/1", failed_game_response, hydra)

      game = Game.new("id" => 1, "team_1_name" => 'Tigers')
      expect { game.destroy! }.to raise_error
    end

    it "raises error on save!" do
      typhoeus_stub(:post, "http://localhost:3000/games", game_response, hydra)

      game = Game.new
      expect { game.save! }.to_not raise_error
    end

    it "raises error on save!" do
      typhoeus_stub(:delete, "http://localhost:3000/games/1", game_response, hydra)

      game = Game.new("id" => 1, "team_1_name" => 'Tigers')
      expect { game.destroy! }.to_not raise_error
    end

    it "should create an object" do
      typhoeus_stub(:post, "http://localhost:3000/games", game_response, hydra)

      game = Game.new
      game.save

      game.id.should == "1"
      game.team_1_name.should == "Bears"
    end

    it "should update an object" do
      update_response = Typhoid::Response.new(:code => 200, :headers => "", :body => {"team_1_name" => "Bears", "id" => "1"}.to_json)
      typhoeus_stub(:put, "http://localhost:3000/games/1", update_response, hydra)

      game = Game.new("id" => 1, "team_1_name" => 'Tigers')
      game.save

      game.resource_exception.should be_nil
      game.team_1_name.should == "Bears"
    end

    it "should delete an object" do
      typhoeus_stub(:delete, "http://localhost:3000/games/1", game_response, hydra)

      game = Game.new("id" => 1, "team_1_name" => 'Tigers')
      game.destroy

      game.resource_exception.should be_nil
    end

    it "should be able to specify save http verb" do
      update_response = Typhoid::Response.new(:code => 200, :headers => "", :body => {"team_1_name" => "Bears", "id" => "1"}.to_json)
      typhoeus_stub(:post, "http://localhost:3000/games/1", update_response, hydra)

      game = Game.new("id" => 1, "team_1_name" => 'Tigers')
      game.save(:post)

      game.resource_exception.should be_nil

    end
  end

  context "handling bad requests" do
    let(:fake_hydra) { Typhoeus::Hydra.new }
    let(:bad_game) { Typhoid::Response.new(:code => 500, :headers => "", :body => "<htmlasdfasdfasdf") }
    before do
      typhoeus_stub(:get, "http://localhost:3000/games/1", bad_game, fake_hydra)
    end

    it "should assign an exception object on a bad request" do
      controller = Controller.new
      controller.remote_resources(fake_hydra) do |req|
        req.resource(:game, Game.get_game)
      end

      bad_game = controller.instance_variable_get("@game")
      bad_game.team_1_name.should be_nil
      expect(bad_game.resource_exception.class).to equal(Typhoid::ReadError)
    end
  end
end
