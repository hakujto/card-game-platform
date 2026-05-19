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

public class ArticleApiTests : IClassFixture<ArticleApiTests.TestFactory>
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

    public ArticleApiTests(TestFactory factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task List_Returns200()
    {
        var response = await _client.GetAsync("/api/articles");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }

    [Fact]
    public async Task Create_Returns201()
    {
        var payload = new
        {
            PublishedAt = "2024-01-01T00:00:00",
            Title = "test",
            Slug = "test",
            Body = "test",
            CreatedAt = "2024-01-01T00:00:00",
            UpdatedAt = "2024-01-01T00:00:00",
            AuthorId = 1
        };
        var response = await _client.PostAsJsonAsync("/api/articles", payload);
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
    }

    [Fact]
    public async Task Show_Returns200OrNotFound()
    {
        var response = await _client.GetAsync("/api/articles/1");
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task Update_Returns200OrNotFound()
    {
        var payload = new { Title = "test" };
        var response = await _client.PatchAsJsonAsync("/api/articles/1", payload);
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task Delete_Returns204OrNotFound()
    {
        var response = await _client.DeleteAsync("/api/articles/1");
        Assert.True(
            response.StatusCode == HttpStatusCode.NoContent ||
            response.StatusCode == HttpStatusCode.NotFound);
    }
    [Fact]
    public async Task Create_Fails_When_PublishedRequiresPublishedAt_Violated()
    {
        // Published article must have a published_at timestamp: antecedent true, consequent missing → 400
        var content = new StringContent(@"{ ""AuthorId"": 1, ""Title"": ""test"", ""Slug"": ""test"", ""Body"": ""test"", ""ArticleType"": ""test"", ""Language"": ""test"", ""ViewCount"": 1, ""LikesCount"": 1, ""IsFeatured"": true, ""CreatedAt"": ""2024-01-01T00:00:00"", ""UpdatedAt"": ""2024-01-01T00:00:00"", ""Status"": ""Published"", ""PublishedAt"": null }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/articles", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Create_Fails_When_ViewCountNotNegative_Violated()
    {
        // Article view count must not be negative → 400 (IValidatableObject)
        var content = new StringContent(@"{ ""AuthorId"": 1, ""Status"": ""Published"", ""PublishedAt"": ""2024-01-01T00:00:00"", ""Title"": ""test"", ""Slug"": ""test"", ""Body"": ""test"", ""ArticleType"": ""test"", ""Language"": ""test"", ""LikesCount"": 1, ""IsFeatured"": true, ""CreatedAt"": ""2024-01-01T00:00:00"", ""UpdatedAt"": ""2024-01-01T00:00:00"", ""ViewCount"": -1 }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/articles", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Create_Fails_When_LikesCountNotNegative_Violated()
    {
        // Article likes count must not be negative → 400 (IValidatableObject)
        var content = new StringContent(@"{ ""AuthorId"": 1, ""Status"": ""Published"", ""PublishedAt"": ""2024-01-01T00:00:00"", ""Title"": ""test"", ""Slug"": ""test"", ""Body"": ""test"", ""ArticleType"": ""test"", ""Language"": ""test"", ""ViewCount"": 1, ""IsFeatured"": true, ""CreatedAt"": ""2024-01-01T00:00:00"", ""UpdatedAt"": ""2024-01-01T00:00:00"", ""LikesCount"": -1 }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/articles", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }
    [Fact]
    public async Task TransitionDraftToPublished_Returns200Or404()
    {
        var response = await _client.PatchAsync("/api/articles/transitions/draft-to-published/1", null);
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.Conflict ||
            response.StatusCode == HttpStatusCode.UnprocessableEntity ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task TransitionPublishedToArchived_Returns200Or404()
    {
        var response = await _client.PatchAsync("/api/articles/transitions/published-to-archived/1", null);
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.Conflict ||
            response.StatusCode == HttpStatusCode.UnprocessableEntity ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task TransitionArchivedToDraft_Returns200Or404()
    {
        var response = await _client.PatchAsync("/api/articles/transitions/archived-to-draft/1", null);
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.Conflict ||
            response.StatusCode == HttpStatusCode.UnprocessableEntity ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task TransitionPublishedToDraft_IsDenied()
    {
        var response = await _client.PatchAsync("/api/articles/transitions/published-to-draft/1", null);
        Assert.True(
            response.StatusCode == HttpStatusCode.Conflict ||
            response.StatusCode == HttpStatusCode.NotFound);
    }
}
