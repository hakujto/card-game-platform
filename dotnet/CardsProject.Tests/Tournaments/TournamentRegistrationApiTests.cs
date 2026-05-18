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

public class TournamentRegistrationApiTests : IClassFixture<TournamentRegistrationApiTests.TestFactory>
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

    public TournamentRegistrationApiTests(TestFactory factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task List_Returns200()
    {
        var response = await _client.GetAsync("/api/tournament_registrations");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }

    [Fact]
    public async Task Create_Returns201()
    {
        var payload = new
        {
            RegisteredAt = "2024-01-01T00:00:00",
            TournamentId = 1,
            PlayerId = 1,
            DeckId = 1
        };
        var response = await _client.PostAsJsonAsync("/api/tournament_registrations", payload);
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
    }

    [Fact]
    public async Task Show_Returns200OrNotFound()
    {
        var response = await _client.GetAsync("/api/tournament_registrations/1");
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task Update_Returns200OrNotFound()
    {
        var payload = new { PointsEarned = 1 };
        var response = await _client.PatchAsJsonAsync("/api/tournament_registrations/1", payload);
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task Delete_Returns204OrNotFound()
    {
        var response = await _client.DeleteAsync("/api/tournament_registrations/1");
        Assert.True(
            response.StatusCode == HttpStatusCode.NoContent ||
            response.StatusCode == HttpStatusCode.NotFound);
    }
    [Fact]
    public async Task Create_Fails_When_PointsEarnedNotNegative_Violated()
    {
        // Points earned must not be negative → 400 (IValidatableObject)
        var content = new StringContent(@"{ ""TournamentId"": 1, ""PlayerId"": 1, ""DeckId"": 1, ""FinalStanding"": 1, ""Seed"": 1, ""Status"": ""test"", ""RegisteredAt"": ""2024-01-01T00:00:00"", ""PointsEarned"": -1 }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/tournament_registrations", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Create_Fails_When_FinalStandingPositive_Violated()
    {
        // Final standing must be greater than zero: antecedent true, consequent missing → 400
        var content = new StringContent(@"{ ""TournamentId"": 1, ""PlayerId"": 1, ""DeckId"": 1, ""Status"": ""test"", ""PointsEarned"": 1, ""RegisteredAt"": ""2024-01-01T00:00:00"", ""FinalStanding"": 1, ""FinalStanding"": 0 }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/tournament_registrations", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Create_Fails_When_SeedPositive_Violated()
    {
        // Seed must be greater than zero: antecedent true, consequent missing → 400
        var content = new StringContent(@"{ ""TournamentId"": 1, ""PlayerId"": 1, ""DeckId"": 1, ""Status"": ""test"", ""PointsEarned"": 1, ""RegisteredAt"": ""2024-01-01T00:00:00"", ""Seed"": 1, ""Seed"": 0 }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/tournament_registrations", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }
}
