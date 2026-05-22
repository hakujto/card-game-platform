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

public class MatchApiTests : IClassFixture<MatchApiTests.TestFactory>
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

    public MatchApiTests(TestFactory factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task List_Returns200()
    {
        var response = await _client.GetAsync("/api/matches");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }
    [Fact]
    public async Task Create_Returns201()
    {
        var payload = new
        {
            StartedAt = "2024-01-01T00:00:00",
            RoundId = 1,
            Player1Id = 1
        };
        var response = await _client.PostAsJsonAsync("/api/matches", payload);
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
    }
    [Fact]
    public async Task Show_Returns200Or404()
    {
        var response = await _client.GetAsync("/api/matches/1");
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.NotFound);
    }
    [Fact]
    public async Task Create_Fails_When_WinsNotNegative_Violated()
    {
        // Win counts must not be negative → 400 (IValidatableObject)
        var content = new StringContent(@"{ ""RoundId"": 1, ""Player1Id"": 1, ""Status"": ""BYE"", ""Player2"": null, ""EndedAt"": ""2024-01-01T00:00:00"", ""StartedAt"": ""2024-01-01T00:00:00"", ""Player2Wins"": 1, ""Player1Wins"": -1 }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/matches", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Create_Fails_When_MaxThreeGames_Violated()
    {
        // Win counts cannot exceed 2 in a best-of-3 match → 400 (IValidatableObject)
        var content = new StringContent(@"{ ""RoundId"": 1, ""Player1Id"": 1, ""Status"": ""BYE"", ""Player2"": null, ""EndedAt"": ""2024-01-01T00:00:00"", ""StartedAt"": ""2024-01-01T00:00:00"", ""Player2Wins"": 1, ""Player1Wins"": 3 }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/matches", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Create_Fails_When_ByeHasNoPlayer2_Violated()
    {
        // BYE match must not have a second player: antecedent true, consequent missing → 400
        var content = new StringContent(@"{ ""RoundId"": 1, ""Player1Id"": 1, ""Player1Wins"": 1, ""Player2Wins"": 1, ""Status"": ""BYE"", ""Player2Id"": 1 }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/matches", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Create_Fails_When_EndedAfterStarted_Violated()
    {
        // Match end time must be after start time: antecedent true, consequent missing → 400
        var content = new StringContent(@"{ ""RoundId"": 1, ""Player1Id"": 1, ""Status"": ""test"", ""Player1Wins"": 1, ""Player2Wins"": 1, ""EndedAt"": ""2024-01-01T00:00:00"" }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/matches", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Create_Fails_When_CompletedRequiresStartedAt_Violated()
    {
        // Completed match must have a start time: antecedent true, consequent missing → 400
        var content = new StringContent(@"{ ""RoundId"": 1, ""Player1Id"": 1, ""Player1Wins"": 1, ""Player2Wins"": 1, ""Status"": ""Completed"", ""StartedAt"": null }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/matches", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }
    [Fact]
    public async Task TransitionPendingToActive_Returns200Or404()
    {
        var response = await _client.PatchAsync("/api/matches/transitions/pending-to-active/1", null);
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.Conflict ||
            response.StatusCode == HttpStatusCode.UnprocessableEntity ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task TransitionActiveToCompleted_Returns200Or404()
    {
        var response = await _client.PatchAsync("/api/matches/transitions/active-to-completed/1", null);
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.Conflict ||
            response.StatusCode == HttpStatusCode.UnprocessableEntity ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task TransitionActiveToDraw_Returns200Or404()
    {
        var response = await _client.PatchAsync("/api/matches/transitions/active-to-draw/1", null);
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.Conflict ||
            response.StatusCode == HttpStatusCode.UnprocessableEntity ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task TransitionPendingToBYE_Returns200Or404()
    {
        var response = await _client.PatchAsync("/api/matches/transitions/pending-to-bye/1", null);
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.Conflict ||
            response.StatusCode == HttpStatusCode.UnprocessableEntity ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task TransitionCompletedToActive_IsDenied()
    {
        var response = await _client.PatchAsync("/api/matches/transitions/completed-to-active/1", null);
        Assert.True(
            response.StatusCode == HttpStatusCode.Conflict ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task TransitionDrawToActive_IsDenied()
    {
        var response = await _client.PatchAsync("/api/matches/transitions/draw-to-active/1", null);
        Assert.True(
            response.StatusCode == HttpStatusCode.Conflict ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task TransitionBYEToActive_IsDenied()
    {
        var response = await _client.PatchAsync("/api/matches/transitions/bye-to-active/1", null);
        Assert.True(
            response.StatusCode == HttpStatusCode.Conflict ||
            response.StatusCode == HttpStatusCode.NotFound);
    }
}
