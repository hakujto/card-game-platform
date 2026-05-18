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

public class OrderApiTests : IClassFixture<OrderApiTests.TestFactory>
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

    public OrderApiTests(TestFactory factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task List_Returns200()
    {
        var response = await _client.GetAsync("/api/orders");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }

    [Fact]
    public async Task Create_Returns201()
    {
        var payload = new
        {
            PaidAt = "2024-01-01T00:00:00",
            TrackingNumber = "test",
            DiscountApplied = 0.00m,
            CreatedAt = "2024-01-01T00:00:00",
            PlayerId = 1
        };
        var response = await _client.PostAsJsonAsync("/api/orders", payload);
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
    }

    [Fact]
    public async Task Show_Returns200OrNotFound()
    {
        var response = await _client.GetAsync("/api/orders/1");
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task Update_Returns200OrNotFound()
    {
        var payload = new { Total = 0.00m };
        var response = await _client.PatchAsJsonAsync("/api/orders/1", payload);
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task Delete_Returns204OrNotFound()
    {
        var response = await _client.DeleteAsync("/api/orders/1");
        Assert.True(
            response.StatusCode == HttpStatusCode.NoContent ||
            response.StatusCode == HttpStatusCode.NotFound);
    }
    [Fact]
    public async Task Create_Fails_When_PaidRequiresPaidAt_Violated()
    {
        // Paid order must have paid_at set: antecedent true, consequent missing → 400
        var content = new StringContent(@"{ ""PlayerId"": 1, ""Total"": 0.00, ""DiscountApplied"": 0.00, ""Currency"": ""test"", ""CreatedAt"": ""2024-01-01T00:00:00"", ""Status"": ""Paid"", ""PaidAt"": null }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/orders", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Create_Fails_When_ShippedRequiresTracking_Violated()
    {
        // Shipped order must have a tracking number: antecedent true, consequent missing → 400
        var content = new StringContent(@"{ ""PlayerId"": 1, ""Total"": 0.00, ""DiscountApplied"": 0.00, ""Currency"": ""test"", ""CreatedAt"": ""2024-01-01T00:00:00"", ""Status"": ""Shipped"", ""TrackingNumber"": null }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/orders", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Create_Fails_When_ShippedAtRequiresShippedStatus_Violated()
    {
        // shipped_at_requires_shipped_status: antecedent true, consequent missing → 400
        var content = new StringContent(@"{ ""PlayerId"": 1, ""Status"": ""test"", ""Total"": 0.00, ""DiscountApplied"": 0.00, ""Currency"": ""test"", ""CreatedAt"": ""2024-01-01T00:00:00"", ""ShippedAt"": ""2024-01-01T00:00:00"" }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/orders", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Create_Fails_When_TotalNotNegative_Violated()
    {
        // Order total must not be negative → 400 (IValidatableObject)
        var content = new StringContent(@"{ ""PlayerId"": 1, ""Status"": ""Paid"", ""PaidAt"": ""2024-01-01T00:00:00"", ""TrackingNumber"": ""test"", ""ShippedAt"": ""2024-01-01T00:00:00"", ""DiscountApplied"": 0.00, ""Currency"": ""test"", ""CreatedAt"": ""2024-01-01T00:00:00"", ""Total"": -1 }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/orders", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }
}
