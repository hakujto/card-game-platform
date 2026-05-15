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

public class TournamentApiTests : IClassFixture<TournamentApiTests.TestFactory>
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

    public TournamentApiTests(TestFactory factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task List_Returns200()
    {
        var response = await _client.GetAsync("/api/tournaments");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }

    [Fact]
    public async Task Create_Returns201()
    {
        var payload = new
        {
            MaxPlayers = 2,
            Name = "test",
            StartTime = "2024-01-01T00:00:00",
            CreatedAt = "2024-01-01T00:00:00",
            SeasonId = 1,
            OrganizerId = 1
        };
        var response = await _client.PostAsJsonAsync("/api/tournaments", payload);
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
    }

    [Fact]
    public async Task Show_Returns200OrNotFound()
    {
        var response = await _client.GetAsync("/api/tournaments/1");
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task Update_Returns200OrNotFound()
    {
        var payload = new { Name = "test" };
        var response = await _client.PatchAsJsonAsync("/api/tournaments/1", payload);
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task Delete_Returns204OrNotFound()
    {
        var response = await _client.DeleteAsync("/api/tournaments/1");
        Assert.True(
            response.StatusCode == HttpStatusCode.NoContent ||
            response.StatusCode == HttpStatusCode.NotFound);
    }
    [Fact]
    public async Task Create_Fails_When_MaxPlayersPositive_Violated()
    {
        // Tournament must allow between 2 and 512 players → 400 (IValidatableObject)
        var content = new StringContent(@"{ ""SeasonId"": 1, ""OrganizerId"": 1, ""EndTime"": ""2024-01-01T00:00:00"", ""Name"": ""test"", ""Format"": ""test"", ""TournamentType"": ""test"", ""Status"": ""test"", ""EntryFee"": 0.00, ""PrizePool"": 0.00, ""StartTime"": ""2024-01-01T00:00:00"", ""IsOnline"": true, ""CreatedAt"": ""2024-01-01T00:00:00"", ""MaxPlayers"": 513 }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/tournaments", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Create_Fails_When_EntryFeeNotNegative_Violated()
    {
        // Entry fee must not be negative → 400 (IValidatableObject)
        var content = new StringContent(@"{ ""SeasonId"": 1, ""OrganizerId"": 1, ""EndTime"": ""2024-01-01T00:00:00"", ""Name"": ""test"", ""Format"": ""test"", ""TournamentType"": ""test"", ""Status"": ""test"", ""MaxPlayers"": 1, ""PrizePool"": 0.00, ""StartTime"": ""2024-01-01T00:00:00"", ""IsOnline"": true, ""CreatedAt"": ""2024-01-01T00:00:00"", ""EntryFee"": -1 }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/tournaments", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Create_Fails_When_PrizePoolNotNegative_Violated()
    {
        // Prize pool must not be negative → 400 (IValidatableObject)
        var content = new StringContent(@"{ ""SeasonId"": 1, ""OrganizerId"": 1, ""EndTime"": ""2024-01-01T00:00:00"", ""Name"": ""test"", ""Format"": ""test"", ""TournamentType"": ""test"", ""Status"": ""test"", ""MaxPlayers"": 1, ""EntryFee"": 0.00, ""StartTime"": ""2024-01-01T00:00:00"", ""IsOnline"": true, ""CreatedAt"": ""2024-01-01T00:00:00"", ""PrizePool"": -1 }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/tournaments", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Create_Fails_When_EndTimeAfterStart_Violated()
    {
        // End time must be after start time: antecedent true, consequent missing → 400
        var content = new StringContent(@"{ ""SeasonId"": 1, ""OrganizerId"": 1, ""Name"": ""test"", ""Format"": ""test"", ""TournamentType"": ""test"", ""Status"": ""test"", ""MaxPlayers"": 1, ""EntryFee"": 0.00, ""PrizePool"": 0.00, ""StartTime"": ""2024-01-01T00:00:00"", ""IsOnline"": true, ""CreatedAt"": ""2024-01-01T00:00:00"", ""EndTime"": ""2024-01-01T00:00:00"" }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/tournaments", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }
}
