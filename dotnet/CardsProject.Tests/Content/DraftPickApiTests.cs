using System.Net;
using System.Net.Http.Json;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using CardsProject.Infrastructure;
using CardsProject.Domain.Content;
using Xunit;

namespace CardsProject.Tests.Content;

public class DraftPickApiTests : IClassFixture<DraftPickApiTests.TestFactory>
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

    public DraftPickApiTests(TestFactory factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task List_Returns200()
    {
        var response = await _client.GetAsync("/api/draft_picks");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }

    [Fact]
    public async Task Create_Returns201()
    {
        var payload = new
        {
            PickNumber = 1,
            PackNumber = 1,
            PickedAt = "2024-01-01T00:00:00",
            ParticipantId = 1,
            CardId = 1
        };
        var response = await _client.PostAsJsonAsync("/api/draft_picks", payload);
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
    }

    [Fact]
    public async Task Show_Returns200OrNotFound()
    {
        var response = await _client.GetAsync("/api/draft_picks/1");
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task Update_Returns200OrNotFound()
    {
        var payload = new { PickNumber = 1 };
        var response = await _client.PatchAsJsonAsync("/api/draft_picks/1", payload);
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task Delete_Returns204OrNotFound()
    {
        var response = await _client.DeleteAsync("/api/draft_picks/1");
        Assert.True(
            response.StatusCode == HttpStatusCode.NoContent ||
            response.StatusCode == HttpStatusCode.NotFound);
    }
    [Fact]
    public async Task Create_Fails_When_PickNumberPositive_Violated()
    {
        // Pick number must be greater than zero → 400 (IValidatableObject)
        var content = new StringContent(@"{ ""ParticipantId"": 1, ""CardId"": 1, ""PackNumber"": 1, ""PickedAt"": ""2024-01-01T00:00:00"", ""PickNumber"": 0 }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/draft_picks", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Create_Fails_When_PackNumberRange_Violated()
    {
        // Pack number must be between 1 and 3 → 400 (IValidatableObject)
        var content = new StringContent(@"{ ""ParticipantId"": 1, ""CardId"": 1, ""PickNumber"": 1, ""PickedAt"": ""2024-01-01T00:00:00"", ""PackNumber"": 4 }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/draft_picks", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }
}
