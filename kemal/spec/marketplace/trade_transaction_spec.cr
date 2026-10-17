require "spec"
require "http/client"
require "json"

describe "TradeTransaction API" do
  it "lists trade_transactions" do
    response = HTTP::Client.get("http://localhost:3000/api/trade_transactions")
    response.status_code.should eq 200
  end

  it "retrieves a trade_transaction" do
    response = HTTP::Client.get("http://localhost:3000/api/trade_transactions/1")
    [200, 404].should contain response.status_code
  end

end
