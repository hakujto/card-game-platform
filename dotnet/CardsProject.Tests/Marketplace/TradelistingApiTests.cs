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

public class TradelistingApiTests : IClassFixture<TradelistingApiTests.TestFactory>
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

    public TradelistingApiTests(TestFactory factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task List_Returns200()
    {
        var response = await _client.GetAsync("/api/tradelistings");
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
        var response = await _client.PostAsJsonAsync("/api/tradelistings", payload);
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
    }

    [Fact]
    public async Task Show_Returns200OrNotFound()
    {
        var response = await _client.GetAsync("/api/tradelistings/1");
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task Update_Returns200OrNotFound()
    {
        var payload = new { AskingPrice = 0.00m };
        var response = await _client.PatchAsJsonAsync("/api/tradelistings/1", payload);
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task Delete_Returns204OrNotFound()
    {
        var response = await _client.DeleteAsync("/api/tradelistings/1");
        Assert.True(
            response.StatusCode == HttpStatusCode.NoContent ||
            response.StatusCode == HttpStatusCode.NotFound);
    }
    [Fact]
    public async Task Create_Fails_When_FixedPriceRequiresAskingPrice_Violated()
    {
        // Fixed price listing must have an asking price: antecedent true, consequent missing → 400
        var content = new StringContent(@"{ ""SellerId"": 1, ""CardId"": 1, ""Foil"": true, ""Condition"": ""test"", ""Quantity"": 1, ""Status"": ""test"", ""CreatedAt"": ""2024-01-01T00:00:00"", ""ListingType"": ""FixedPrice"", ""AskingPrice"": null }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/tradelistings", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Create_Fails_When_AuctionRequiresStartPriceAndEndTime_Violated()
    {
        // Auction listing must have a start price and end time: antecedent true, consequent missing → 400
        var content = new StringContent(@"{ ""SellerId"": 1, ""CardId"": 1, ""Foil"": true, ""Condition"": ""test"", ""Quantity"": 1, ""Status"": ""test"", ""CreatedAt"": ""2024-01-01T00:00:00"", ""ListingType"": ""Auction"", ""AuctionStartPrice"": null }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/tradelistings", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Create_Fails_When_QuantityPositive_Violated()
    {
        // Listing quantity must be between 1 and 9999 → 400 (IValidatableObject)
        var content = new StringContent(@"{ ""SellerId"": 1, ""CardId"": 1, ""ListingType"": ""FixedPrice"", ""AskingPrice"": 0.00, ""AuctionStartPrice"": 0.00, ""AuctionEndTime"": ""2024-01-01T00:00:00"", ""Foil"": true, ""Condition"": ""test"", ""Status"": ""test"", ""CreatedAt"": ""2024-01-01T00:00:00"", ""Quantity"": 10000 }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/tradelistings", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }
}
