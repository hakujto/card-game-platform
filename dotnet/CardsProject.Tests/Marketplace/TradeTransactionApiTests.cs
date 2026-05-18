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

public class TradeTransactionApiTests : IClassFixture<TradeTransactionApiTests.TestFactory>
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

    public TradeTransactionApiTests(TestFactory factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task List_Returns200()
    {
        var response = await _client.GetAsync("/api/trade_transactions");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }

    [Fact]
    public async Task Create_Returns201()
    {
        var payload = new
        {
            FinalPrice = 0.01m,
            CompletedAt = "2024-01-01T00:00:00",
            PlatformFee = 0.01m,
            ListingId = 1,
            BuyerId = 1,
            SellerId = 1
        };
        var response = await _client.PostAsJsonAsync("/api/trade_transactions", payload);
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
    }

    [Fact]
    public async Task Show_Returns200OrNotFound()
    {
        var response = await _client.GetAsync("/api/trade_transactions/1");
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task Update_Returns200OrNotFound()
    {
        var payload = new { FinalPrice = 0.01m };
        var response = await _client.PatchAsJsonAsync("/api/trade_transactions/1", payload);
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task Delete_Returns204OrNotFound()
    {
        var response = await _client.DeleteAsync("/api/trade_transactions/1");
        Assert.True(
            response.StatusCode == HttpStatusCode.NoContent ||
            response.StatusCode == HttpStatusCode.NotFound);
    }
    [Fact]
    public async Task Create_Fails_When_FeeNotNegative_Violated()
    {
        // Platform fee must not be negative → 400 (IValidatableObject)
        var content = new StringContent(@"{ ""ListingId"": 1, ""BuyerId"": 1, ""SellerId"": 1, ""Status"": ""Completed"", ""CompletedAt"": ""2024-01-01T00:00:00"", ""FinalPrice"": 0.00, ""PlatformFee"": -1 }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/trade_transactions", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Create_Fails_When_FinalPricePositive_Violated()
    {
        // Transaction final price must be greater than zero → 400 (IValidatableObject)
        var content = new StringContent(@"{ ""ListingId"": 1, ""BuyerId"": 1, ""SellerId"": 1, ""Status"": ""Completed"", ""CompletedAt"": ""2024-01-01T00:00:00"", ""PlatformFee"": 0.00, ""FinalPrice"": 0.00 }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/trade_transactions", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Create_Fails_When_CompletedRequiresCompletedAt_Violated()
    {
        // Completed transaction must have a completed_at timestamp: antecedent true, consequent missing → 400
        var content = new StringContent(@"{ ""ListingId"": 1, ""BuyerId"": 1, ""SellerId"": 1, ""FinalPrice"": 0.00, ""PlatformFee"": 0.00, ""Status"": ""Completed"", ""CompletedAt"": null }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/trade_transactions", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }
}
