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

public class ProductApiTests : IClassFixture<ProductApiTests.TestFactory>
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

    public ProductApiTests(TestFactory factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task List_Returns200()
    {
        var response = await _client.GetAsync("/api/products");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }

    [Fact]
    public async Task Create_Returns201()
    {
        var payload = new
        {
            Price = 0.01m,
            Name = "test"
        };
        var response = await _client.PostAsJsonAsync("/api/products", payload);
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
    }

    [Fact]
    public async Task Show_Returns200OrNotFound()
    {
        var response = await _client.GetAsync("/api/products/1");
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task Update_Returns200OrNotFound()
    {
        var payload = new { Name = "test" };
        var response = await _client.PatchAsJsonAsync("/api/products/1", payload);
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task Delete_Returns204OrNotFound()
    {
        var response = await _client.DeleteAsync("/api/products/1");
        Assert.True(
            response.StatusCode == HttpStatusCode.NoContent ||
            response.StatusCode == HttpStatusCode.NotFound);
    }
    [Fact]
    public async Task Create_Fails_When_PricePositive_Violated()
    {
        // Product price must be greater than zero → 400 (IValidatableObject)
        var content = new StringContent(@"{ ""Name"": ""test"", ""ProductType"": ""test"", ""Stock"": 1, ""Active"": true, ""DiscountPercent"": 1, ""Featured"": true, ""Price"": 0.00 }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/products", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Create_Fails_When_StockNotNegative_Violated()
    {
        // Product stock must not be negative → 400 (IValidatableObject)
        var content = new StringContent(@"{ ""Name"": ""test"", ""ProductType"": ""test"", ""Price"": 0.00, ""Active"": true, ""DiscountPercent"": 1, ""Featured"": true, ""Stock"": -1 }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/products", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Create_Fails_When_DiscountPercentRange_Violated()
    {
        // Product discount percent must be between 0 and 100 → 400 (IValidatableObject)
        var content = new StringContent(@"{ ""Name"": ""test"", ""ProductType"": ""test"", ""Price"": 0.00, ""Stock"": 1, ""Active"": true, ""Featured"": true, ""DiscountPercent"": 101 }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/products", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }
}
