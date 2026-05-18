using System.Net;
using System.Net.Http.Json;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using CardsProject.Infrastructure;
using CardsProject.Domain.Tournaments;
using Xunit;

namespace CardsProject.Tests.Tournaments;

public class AwardedPrizeApiTests : IClassFixture<AwardedPrizeApiTests.TestFactory>
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

    public AwardedPrizeApiTests(TestFactory factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task List_Returns200()
    {
        var response = await _client.GetAsync("/api/awarded_prizes");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }

    [Fact]
    public async Task Create_Returns201()
    {
        var payload = new
        {
            Claimed = false,
            FinalPlacement = 1,
            AwardedAt = "2024-01-01T00:00:00",
            PrizeId = 1,
            PlayerId = 1
        };
        var response = await _client.PostAsJsonAsync("/api/awarded_prizes", payload);
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
    }

    [Fact]
    public async Task Show_Returns200OrNotFound()
    {
        var response = await _client.GetAsync("/api/awarded_prizes/1");
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task Update_Returns200OrNotFound()
    {
        var payload = new { FinalPlacement = 1 };
        var response = await _client.PatchAsJsonAsync("/api/awarded_prizes/1", payload);
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task Delete_Returns204OrNotFound()
    {
        var response = await _client.DeleteAsync("/api/awarded_prizes/1");
        Assert.True(
            response.StatusCode == HttpStatusCode.NoContent ||
            response.StatusCode == HttpStatusCode.NotFound);
    }
    [Fact]
    public async Task Create_Fails_When_ClaimedRequiresClaimedAt_Violated()
    {
        // Claimed prize must have a claimed_at timestamp: antecedent true, consequent missing → 400
        var content = new StringContent(@"{ ""PrizeId"": 1, ""PlayerId"": 1, ""FinalPlacement"": 1, ""AwardedAt"": ""2024-01-01T00:00:00"", ""Claimed"": true, ""ClaimedAt"": null }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/awarded_prizes", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Create_Fails_When_FinalPlacementPositive_Violated()
    {
        // Final placement must be greater than zero → 400 (IValidatableObject)
        var content = new StringContent(@"{ ""PrizeId"": 1, ""PlayerId"": 1, ""Claimed"": true, ""ClaimedAt"": ""2024-01-01T00:00:00"", ""AwardedAt"": ""2024-01-01T00:00:00"", ""FinalPlacement"": 0 }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/awarded_prizes", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }
}
