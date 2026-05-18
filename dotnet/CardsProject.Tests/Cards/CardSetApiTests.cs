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

public class CardSetApiTests : IClassFixture<CardSetApiTests.TestFactory>
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

    public CardSetApiTests(TestFactory factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task List_Returns200()
    {
        var response = await _client.GetAsync("/api/card_sets");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }

    [Fact]
    public async Task Create_Returns201()
    {
        var payload = new
        {
            TotalCards = 1,
            IsRotated = false,
            Name = "test",
            Code = "test",
            ReleaseDate = "2024-01-01"
        };
        var response = await _client.PostAsJsonAsync("/api/card_sets", payload);
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
    }

    [Fact]
    public async Task Show_Returns200OrNotFound()
    {
        var response = await _client.GetAsync("/api/card_sets/1");
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task Update_Returns200OrNotFound()
    {
        var payload = new { Name = "test" };
        var response = await _client.PatchAsJsonAsync("/api/card_sets/1", payload);
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task Delete_Returns204OrNotFound()
    {
        var response = await _client.DeleteAsync("/api/card_sets/1");
        Assert.True(
            response.StatusCode == HttpStatusCode.NoContent ||
            response.StatusCode == HttpStatusCode.NotFound);
    }
    [Fact]
    public async Task Create_Fails_When_TotalCardsPositive_Violated()
    {
        // Card set must have at least one card → 400 (IValidatableObject)
        var content = new StringContent(@"{ ""RotationDate"": ""2024-01-01"", ""IsRotated"": true, ""Name"": ""test"", ""Code"": ""test"", ""ReleaseDate"": ""2024-01-01"", ""SetType"": ""test"", ""TotalCards"": 0 }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/card_sets", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Create_Fails_When_RotationDateAfterRelease_Violated()
    {
        // Rotation date must be after release date: antecedent true, consequent missing → 400
        var content = new StringContent(@"{ ""Name"": ""test"", ""Code"": ""test"", ""ReleaseDate"": ""2024-01-01"", ""SetType"": ""test"", ""TotalCards"": 1, ""IsRotated"": true, ""RotationDate"": ""2024-01-01"" }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/card_sets", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Create_Fails_When_RotatedSetHasRotationDate_Violated()
    {
        // Rotated set must have a rotation date: antecedent true, consequent missing → 400
        var content = new StringContent(@"{ ""Name"": ""test"", ""Code"": ""test"", ""ReleaseDate"": ""2024-01-01"", ""SetType"": ""test"", ""TotalCards"": 1, ""IsRotated"": true, ""RotationDate"": null }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/card_sets", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }
}
