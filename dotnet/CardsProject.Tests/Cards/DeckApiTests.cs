using System.Net;
using System.Net.Http.Json;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using CardsProject.Infrastructure;
using CardsProject.Domain.Cards;
using Xunit;

namespace CardsProject.Tests.Cards;

public class DeckApiTests : IClassFixture<DeckApiTests.TestFactory>
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

    public DeckApiTests(TestFactory factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task List_Returns200()
    {
        var response = await _client.GetAsync("/api/decks");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }

    [Fact]
    public async Task Create_Returns201()
    {
        var payload = new
        {
            IsTournamentLegal = false,
            Name = "test",
            CreatedAt = "2024-01-01T00:00:00",
            UpdatedAt = "2024-01-01T00:00:00",
            PlayerId = 1
        };
        var response = await _client.PostAsJsonAsync("/api/decks", payload);
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
    }

    [Fact]
    public async Task Show_Returns200OrNotFound()
    {
        var response = await _client.GetAsync("/api/decks/1");
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task Update_Returns200OrNotFound()
    {
        var payload = new { Name = "test" };
        var response = await _client.PatchAsJsonAsync("/api/decks/1", payload);
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task Delete_Returns204OrNotFound()
    {
        var response = await _client.DeleteAsync("/api/decks/1");
        Assert.True(
            response.StatusCode == HttpStatusCode.NoContent ||
            response.StatusCode == HttpStatusCode.NotFound);
    }
    [Fact]
    public async Task Create_Fails_When_WinsNotNegative_Violated()
    {
        // Deck wins count must not be negative → 400 (IValidatableObject)
        var content = new StringContent(@"{ ""PlayerId"": 1, ""IsTournamentLegal"": true, ""IsPublic"": true, ""Name"": ""test"", ""Format"": ""test"", ""Losses"": 1, ""Draws"": 1, ""CreatedAt"": ""2024-01-01T00:00:00"", ""UpdatedAt"": ""2024-01-01T00:00:00"", ""Wins"": -1 }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/decks", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Create_Fails_When_LossesNotNegative_Violated()
    {
        // Deck losses count must not be negative → 400 (IValidatableObject)
        var content = new StringContent(@"{ ""PlayerId"": 1, ""IsTournamentLegal"": true, ""IsPublic"": true, ""Name"": ""test"", ""Format"": ""test"", ""Wins"": 1, ""Draws"": 1, ""CreatedAt"": ""2024-01-01T00:00:00"", ""UpdatedAt"": ""2024-01-01T00:00:00"", ""Losses"": -1 }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/decks", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Create_Fails_When_DrawsNotNegative_Violated()
    {
        // Deck draws count must not be negative → 400 (IValidatableObject)
        var content = new StringContent(@"{ ""PlayerId"": 1, ""IsTournamentLegal"": true, ""IsPublic"": true, ""Name"": ""test"", ""Format"": ""test"", ""Wins"": 1, ""Losses"": 1, ""CreatedAt"": ""2024-01-01T00:00:00"", ""UpdatedAt"": ""2024-01-01T00:00:00"", ""Draws"": -1 }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/decks", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Create_Fails_When_TournamentLegalDeckMustBeValidated_Violated()
    {
        // Tournament-legal deck must be made public: antecedent true, consequent missing → 400
        var content = new StringContent(@"{ ""PlayerId"": 1, ""Name"": ""test"", ""Format"": ""test"", ""Wins"": 1, ""Losses"": 1, ""Draws"": 1, ""CreatedAt"": ""2024-01-01T00:00:00"", ""UpdatedAt"": ""2024-01-01T00:00:00"", ""IsTournamentLegal"": true, ""IsPublic"": false }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/decks", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }
}
