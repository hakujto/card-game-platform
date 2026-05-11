using System.Net;
using System.Net.Http.Json;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using CardsProject.Infrastructure;
using Xunit;

namespace CardsProject.Tests.Tournaments;

public class GameApiTests : IClassFixture<GameApiTests.TestFactory>
{
    public class TestFactory : WebApplicationFactory<Program>, IDisposable
    {
        private readonly SqliteConnection _connection;

        public TestFactory()
        {
            _connection = new SqliteConnection("Data Source=:memory:");
            _connection.Open();
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

    public GameApiTests(TestFactory factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task List_Returns200()
    {
        var response = await _client.GetAsync("/api/games");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }

    [Fact]
    public async Task Create_Returns201()
    {
        var payload = new
        {
        GameNumber = 1
        };
        var response = await _client.PostAsJsonAsync("/api/games", payload);
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
    }

    [Fact]
    public async Task Show_Returns200OrNotFound()
    {
        var response = await _client.GetAsync("/api/games/1");
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task Update_Returns200OrNotFound()
    {
        var payload = new { GameNumber = 1 };
        var response = await _client.PatchAsJsonAsync("/api/games/1", payload);
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task Delete_Returns204OrNotFound()
    {
        var response = await _client.DeleteAsync("/api/games/1");
        Assert.True(
            response.StatusCode == HttpStatusCode.NoContent ||
            response.StatusCode == HttpStatusCode.NotFound);
    }
}
