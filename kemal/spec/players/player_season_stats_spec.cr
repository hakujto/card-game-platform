require "spec"
require "http/client"
require "json"

describe "PlayerSeasonStats API" do
  it "lists player_season_statses" do
    response = HTTP::Client.get("http://localhost:3000/api/player_season_statses")
    response.status_code.should eq 200
  end

  it "retrieves a player_season_stats" do
    response = HTTP::Client.get("http://localhost:3000/api/player_season_statses/1")
    [200, 404].should contain response.status_code
  end

end
