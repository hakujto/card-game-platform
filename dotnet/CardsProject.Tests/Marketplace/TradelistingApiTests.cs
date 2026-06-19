using System.Net;
using System.Net.Http.Json;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using CardsProject.Infrastructure;
using CardsProject.Domain.Marketplace;
using Xunit;

namespace CardsProject.Tests.Marketplace;

public class TradeListingApiTests : IClassFixture<TradeListingApiTests.TestFactory>
{
    public class TestFactory : WebApplicationFactory<Program>, IDisposable
    {
        private readonly SqliteConnection _connection;

        public TestFactory()
        {
            _connection = new SqliteConnection("Data Source=:memory:");
            _connection.Open();
            using var cmd = _connection.CreateCommand();
            cmd.CommandText = "PRAGMA foreign_keys = OFF;";
            cmd.ExecuteNonQuery();
        }

        protected override void ConfigureWebHost(Microsoft.AspNetCore.Hosting.IWebHostBuilder builder)
        {
            builder.ConfigureServices(services =>
            {
                var descriptor = services.SingleOrDefault(
                    d => d.ServiceType == typeof(DbContextOptions<AppDbContext>));
                if (descriptor != null) services.Remove(descriptor);
                services.AddDbContext<AppDbContext>(opt =>
                    opt.UseSqlite(_connection));
            });
        }

        protected override void Dispose(bool disposing)
        {
            base.Dispose(disposing);
            if (disposing) _connection.Dispose();
        }
    }

    private readonly HttpClient _client;

    public TradeListingApiTests(TestFactory factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task List_Returns200()
    {
        var response = await _client.GetAsync("/api/trade_listings");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }
    [Fact]
    public async Task Create_Returns201()
    {
        var payload = new
        {
            AskingPrice = 0.00m,
            AuctionStartPrice = 0.00m,
            AuctionEndTime = "2024-01-01T00:00:00",
            CreatedAt = "2024-01-01T00:00:00",
            SellerId = 1,
            CardId = 1
        };
        var response = await _client.PostAsJsonAsync("/api/trade_listings", payload);
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
    }
    [Fact]
    public async Task Show_Returns200Or404()
    {
        var response = await _client.GetAsync("/api/trade_listings/1");
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.NotFound);
    }
    [Fact]
    public async Task Update_Returns200Or404()
    {
        var payload = new { AskingPrice = 0.00m };
        var response = await _client.PatchAsJsonAsync("/api/trade_listings/1", payload);
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.NotFound);
    }
    [Fact]
    public async Task Search_Returns200()
    {
        var response = await _client.GetAsync("/api/trade_listings?q=test");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }
    [Fact]
    public async Task Create_Fails_When_FixedPriceRequiresAskingPrice_Violated()
    {
        // Fixed price listing must have an asking price: antecedent true, consequent missing → 400
        var content = new StringContent(@"{ ""SellerId"": 1, ""CardId"": 1, ""Status"": ""test"", ""Foil"": true, ""Condition"": ""test"", ""Quantity"": 1, ""CreatedAt"": ""2024-01-01T00:00:00"", ""ListingType"": ""FixedPrice"", ""AskingPrice"": null }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/trade_listings", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Create_Fails_When_AuctionRequiresStartPriceAndEndTime_Violated()
    {
        // Auction listing must have a start price and end time: antecedent true, consequent missing → 400
        var content = new StringContent(@"{ ""SellerId"": 1, ""CardId"": 1, ""Status"": ""test"", ""Foil"": true, ""Condition"": ""test"", ""Quantity"": 1, ""CreatedAt"": ""2024-01-01T00:00:00"", ""ListingType"": ""Auction"", ""AuctionStartPrice"": null }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/trade_listings", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Create_Fails_When_QuantityPositive_Violated()
    {
        // Listing quantity must be between 1 and 9999 → 400 (IValidatableObject)
        var content = new StringContent(@"{ ""SellerId"": 1, ""CardId"": 1, ""ListingType"": ""FixedPrice"", ""AskingPrice"": 0.00, ""AuctionStartPrice"": 0.00, ""auctionEndTime"": ""2024-01-01T00:00:00"", ""Status"": ""test"", ""Foil"": true, ""Condition"": ""test"", ""CreatedAt"": ""2024-01-01T00:00:00"", ""Quantity"": 10000 }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/trade_listings", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }
    [Fact]
    public async Task TransitionPendingToActive_Returns200Or404()
    {
        var response = await _client.PatchAsync("/api/trade_listings/transitions/pending-to-active/1", null);
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.Conflict ||
            response.StatusCode == HttpStatusCode.UnprocessableEntity ||
            response.StatusCode == HttpStatusCode.Unauthorized ||
            response.StatusCode == HttpStatusCode.Forbidden ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task TransitionActiveToSold_Returns200Or404()
    {
        var response = await _client.PatchAsync("/api/trade_listings/transitions/active-to-sold/1", null);
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.Conflict ||
            response.StatusCode == HttpStatusCode.UnprocessableEntity ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task TransitionActiveToExpired_Returns200Or404()
    {
        var response = await _client.PatchAsync("/api/trade_listings/transitions/active-to-expired/1", null);
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.Conflict ||
            response.StatusCode == HttpStatusCode.UnprocessableEntity ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task TransitionActiveToCancelled_Returns200Or404()
    {
        var response = await _client.PatchAsync("/api/trade_listings/transitions/active-to-cancelled/1", null);
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.Conflict ||
            response.StatusCode == HttpStatusCode.UnprocessableEntity ||
            response.StatusCode == HttpStatusCode.Unauthorized ||
            response.StatusCode == HttpStatusCode.Forbidden ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task TransitionSoldToActive_IsDenied()
    {
        var response = await _client.PatchAsync("/api/trade_listings/transitions/sold-to-active/1", null);
        Assert.True(
            response.StatusCode == HttpStatusCode.Conflict ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task TransitionExpiredToActive_IsDenied()
    {
        var response = await _client.PatchAsync("/api/trade_listings/transitions/expired-to-active/1", null);
        Assert.True(
            response.StatusCode == HttpStatusCode.Conflict ||
            response.StatusCode == HttpStatusCode.NotFound);
    }
}
