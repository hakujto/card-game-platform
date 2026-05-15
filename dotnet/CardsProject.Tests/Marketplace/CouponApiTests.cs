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

public class CouponApiTests : IClassFixture<CouponApiTests.TestFactory>
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

    public CouponApiTests(TestFactory factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task List_Returns200()
    {
        var response = await _client.GetAsync("/api/coupons");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }

    [Fact]
    public async Task Create_Returns201()
    {
        var payload = new
        {
            DiscountValue = 1.00m,
            ValidUntil = DateTime.Parse("2024-01-01T00:00:01"),
            Code = "test",
            ValidFrom = new DateTime(2024, 1, 1)
        };
        var response = await _client.PostAsJsonAsync("/api/coupons", payload);
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
    }

    [Fact]
    public async Task Show_Returns200OrNotFound()
    {
        var response = await _client.GetAsync("/api/coupons/1");
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task Update_Returns200OrNotFound()
    {
        var payload = new { Code = "test" };
        var response = await _client.PatchAsJsonAsync("/api/coupons/1", payload);
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task Delete_Returns204OrNotFound()
    {
        var response = await _client.DeleteAsync("/api/coupons/1");
        Assert.True(
            response.StatusCode == HttpStatusCode.NoContent ||
            response.StatusCode == HttpStatusCode.NotFound);
    }
    [Fact]
    public async Task Create_Fails_When_DiscountValuePositive_Violated()
    {
        // Discount value must be greater than zero → 400 (IValidatableObject)
        var content = new StringContent(@"{ ""DiscountType"": ""Percent"", ""MaxUses"": 1, ""Code"": ""test"", ""MinOrderValue"": 0.00, ""UsesCount"": 1, ""ValidFrom"": ""2024-01-01T00:00:00"", ""ValidUntil"": ""2024-01-01T00:00:00"", ""IsActive"": true, ""DiscountValue"": 0.00 }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/coupons", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Create_Fails_When_PercentDiscountRange_Violated()
    {
        // Percent discount must be between 1 and 100: antecedent true, consequent missing → 400
        var content = new StringContent(@"{ ""Code"": ""test"", ""MinOrderValue"": 0.00, ""UsesCount"": 1, ""ValidFrom"": ""2024-01-01T00:00:00"", ""ValidUntil"": ""2024-01-01T00:00:00"", ""IsActive"": true, ""DiscountType"": ""Percent"", ""DiscountValue"": 101 }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/coupons", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Create_Fails_When_UsesNotExceedMax_Violated()
    {
        // Coupon uses count cannot exceed max_uses: antecedent true, consequent missing → 400
        var content = new StringContent(@"{ ""Code"": ""test"", ""DiscountType"": ""test"", ""DiscountValue"": 0.00, ""MinOrderValue"": 0.00, ""UsesCount"": 1, ""ValidFrom"": ""2024-01-01T00:00:00"", ""ValidUntil"": ""2024-01-01T00:00:00"", ""IsActive"": true, ""MaxUses"": 1 }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/coupons", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }
}
