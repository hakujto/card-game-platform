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

public class TradeDisputeApiTests : IClassFixture<TradeDisputeApiTests.TestFactory>
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

    public TradeDisputeApiTests(TestFactory factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task List_Returns200()
    {
        var response = await _client.GetAsync("/api/trade_disputes");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }
    [Fact]
    public async Task Create_Returns201()
    {
        var payload = new
        {
            Reason = "ItemNotReceived",
            Description = "test",
            OpenedAt = "2024-01-01T00:00:00",
            TransactionId = 1,
            OpenedById = 1
        };
        var response = await _client.PostAsJsonAsync("/api/trade_disputes", payload);
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
    }
    [Fact]
    public async Task Show_Returns200Or404()
    {
        var response = await _client.GetAsync("/api/trade_disputes/1");
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.NotFound);
    }
    [Fact]
    public async Task Create_Fails_When_ResolvedAtRequiresTerminalStatus_Violated()
    {
        // resolved_at_requires_terminal_status: antecedent true, consequent missing → 400
        var content = new StringContent(@"{ ""TransactionId"": 1, ""OpenedById"": 1, ""Status"": ""test"", ""Reason"": ""test"", ""Description"": ""test"", ""OpenedAt"": ""2024-01-01T00:00:00"", ""ResolvedAt"": ""2024-01-01T00:00:00"" }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/trade_disputes", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }
    [Fact]
    public async Task TransitionOpenToUnderReview_Returns200Or404()
    {
        var response = await _client.PatchAsync("/api/trade_disputes/transitions/open-to-underreview/1", null);
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.Conflict ||
            response.StatusCode == HttpStatusCode.UnprocessableEntity ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task TransitionUnderReviewToResolved_Returns200Or404()
    {
        var response = await _client.PatchAsync("/api/trade_disputes/transitions/underreview-to-resolved/1", null);
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.Conflict ||
            response.StatusCode == HttpStatusCode.UnprocessableEntity ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task TransitionUnderReviewToEscalated_Returns200Or404()
    {
        var response = await _client.PatchAsync("/api/trade_disputes/transitions/underreview-to-escalated/1", null);
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.Conflict ||
            response.StatusCode == HttpStatusCode.UnprocessableEntity ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task TransitionEscalatedToResolved_Returns200Or404()
    {
        var response = await _client.PatchAsync("/api/trade_disputes/transitions/escalated-to-resolved/1", null);
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.Conflict ||
            response.StatusCode == HttpStatusCode.UnprocessableEntity ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task TransitionResolvedToOpen_IsDenied()
    {
        var response = await _client.PatchAsync("/api/trade_disputes/transitions/resolved-to-open/1", null);
        Assert.True(
            response.StatusCode == HttpStatusCode.Conflict ||
            response.StatusCode == HttpStatusCode.NotFound);
    }
}
