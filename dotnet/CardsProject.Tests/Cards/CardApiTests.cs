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

public class CardApiTests : IClassFixture<CardApiTests.TestFactory>
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

    public CardApiTests(TestFactory factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task List_Returns200()
    {
        var response = await _client.GetAsync("/api/cards");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }

    [Fact]
    public async Task Create_Returns201()
    {
        var payload = new
        {
            Attack = 1,
            Defense = 1,
            Loyalty = 1,
            IsBanned = false,
            IsRestricted = false,
            Name = "test",
            ManaColors = "White",
            Description = "test",
            LegalFormats = "Standard",
            SetId = 1
        };
        var response = await _client.PostAsJsonAsync("/api/cards", payload);
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
    }

    [Fact]
    public async Task Show_Returns200OrNotFound()
    {
        var response = await _client.GetAsync("/api/cards/1");
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task Update_Returns200OrNotFound()
    {
        var payload = new { Name = "test" };
        var response = await _client.PatchAsJsonAsync("/api/cards/1", payload);
        Assert.True(
            response.StatusCode == HttpStatusCode.OK ||
            response.StatusCode == HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task Delete_Returns204OrNotFound()
    {
        var response = await _client.DeleteAsync("/api/cards/1");
        Assert.True(
            response.StatusCode == HttpStatusCode.NoContent ||
            response.StatusCode == HttpStatusCode.NotFound);
    }
    [Fact]
    public async Task Create_Fails_When_CreatureRequiresStats_Violated()
    {
        // Creature card must have attack and defense: antecedent true, consequent missing → 400
        var content = new StringContent(@"{ ""SetId"": 1, ""Name"": ""test"", ""Rarity"": ""test"", ""ManaCost"": 1, ""ManaColors"": ""test"", ""Description"": ""test"", ""LegalFormats"": ""test"", ""IsBanned"": true, ""IsRestricted"": true, ""PowerLevel"": 1, ""CardType"": ""Creature"", ""Attack"": null }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/cards", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Create_Fails_When_PlaneswalkerRequiresLoyalty_Violated()
    {
        // Planeswalker card must have loyalty: antecedent true, consequent missing → 400
        var content = new StringContent(@"{ ""SetId"": 1, ""Name"": ""test"", ""Rarity"": ""test"", ""ManaCost"": 1, ""ManaColors"": ""test"", ""Description"": ""test"", ""LegalFormats"": ""test"", ""IsBanned"": true, ""IsRestricted"": true, ""PowerLevel"": 1, ""CardType"": ""Planeswalker"", ""Loyalty"": null }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/cards", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Create_Fails_When_ManaCostRange_Violated()
    {
        // mana_cost must be between 0 and 20 → 400 (IValidatableObject)
        var content = new StringContent(@"{ ""SetId"": 1, ""CardType"": ""Creature"", ""Attack"": 1, ""Defense"": 1, ""Loyalty"": 1, ""Name"": ""test"", ""Rarity"": ""test"", ""ManaColors"": ""test"", ""Description"": ""test"", ""LegalFormats"": ""test"", ""IsBanned"": true, ""IsRestricted"": true, ""PowerLevel"": 1, ""ManaCost"": 21 }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/cards", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Create_Fails_When_PowerLevelRange_Violated()
    {
        // power_level must be between 1 and 10 → 400 (IValidatableObject)
        var content = new StringContent(@"{ ""SetId"": 1, ""CardType"": ""Creature"", ""Attack"": 1, ""Defense"": 1, ""Loyalty"": 1, ""Name"": ""test"", ""Rarity"": ""test"", ""ManaCost"": 1, ""ManaColors"": ""test"", ""Description"": ""test"", ""LegalFormats"": ""test"", ""IsBanned"": true, ""IsRestricted"": true, ""PowerLevel"": 11 }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/cards", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Create_Fails_When_NotBannedAndRestricted_Violated()
    {
        // Card cannot be both banned and restricted at the same time → 400 (IValidatableObject)
        var content = new StringContent(@"{ ""SetId"": 1, ""CardType"": ""Creature"", ""Attack"": 1, ""Defense"": 1, ""Loyalty"": 1, ""Name"": ""test"", ""Rarity"": ""test"", ""ManaCost"": 1, ""ManaColors"": ""test"", ""Description"": ""test"", ""LegalFormats"": ""test"", ""PowerLevel"": 1, ""IsBanned"": true, ""IsRestricted"": true }", System.Text.Encoding.UTF8, "application/json");
        var response = await _client.PostAsync("/api/cards", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }
}
