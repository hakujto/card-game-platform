require "spec"
require "http/client"
require "json"

describe "PlayerAchievement API" do
  it "lists player_achievements" do
    response = HTTP::Client.get("http://localhost:3000/api/player_achievements")
    response.status_code.should eq 200
  end

  it "retrieves a player_achievement" do
    response = HTTP::Client.get("http://localhost:3000/api/player_achievements/1")
    [200, 404].should contain response.status_code
  end

end
