using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;
using CardsProject.Domain.Cards;
using CardsProject.Domain.Players;
using CardsProject.Domain.Tournaments;
using CardsProject.Domain.Marketplace;
using CardsProject.Domain.Content;
using CardsProject.Services.Cards;
using CardsProject.Services.Players;
using CardsProject.Services.Tournaments;
using CardsProject.Services.Marketplace;
using CardsProject.Services.Content;
using CardsProject.Infrastructure;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddDbContext<AppDbContext>(opt =>
    opt.UseSqlite(builder.Configuration.GetConnectionString("DefaultConnection") ?? "Data Source=app.db"));

builder.Services.AddIdentityApiEndpoints<ApplicationUser>(opt =>
{
    opt.Password.RequireDigit = false;
    opt.Password.RequireNonAlphanumeric = false;
    opt.Password.RequiredLength = 6;
})
.AddEntityFrameworkStores<AppDbContext>();

// Prevent Identity cookie from returning 403 to API clients (browsers with stale cookies)
builder.Services.ConfigureApplicationCookie(opt =>
{
    opt.Events.OnRedirectToAccessDenied = ctx => { ctx.Response.StatusCode = 401; return System.Threading.Tasks.Task.CompletedTask; };
    opt.Events.OnRedirectToLogin = ctx => { ctx.Response.StatusCode = 401; return System.Threading.Tasks.Task.CompletedTask; };
});

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "CardsProject API", Version = "v1" });
});

builder.Services.AddCors(opt =>
    opt.AddDefaultPolicy(p => p.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader()));

builder.Services.AddScoped<CardService>();
builder.Services.AddScoped<CardSetService>();
builder.Services.AddScoped<CardRulingService>();
builder.Services.AddScoped<CardAbilityService>();
builder.Services.AddScoped<DeckService>();
builder.Services.AddScoped<DeckCardService>();
builder.Services.AddScoped<DeckSideboardCardService>();
builder.Services.AddScoped<DeckTagService>();
builder.Services.AddScoped<DeckTagAssignmentService>();
builder.Services.AddScoped<PlayerService>();
builder.Services.AddScoped<PlayerSeasonStatsService>();
builder.Services.AddScoped<PlayerCollectionService>();
builder.Services.AddScoped<FriendshipService>();
builder.Services.AddScoped<AchievementService>();
builder.Services.AddScoped<PlayerAchievementService>();
builder.Services.AddScoped<CraftingRecipeService>();
builder.Services.AddScoped<CraftingIngredientService>();
builder.Services.AddScoped<SeasonService>();
builder.Services.AddScoped<TournamentService>();
builder.Services.AddScoped<TournamentJudgeService>();
builder.Services.AddScoped<TournamentRegistrationService>();
builder.Services.AddScoped<TournamentRoundService>();
builder.Services.AddScoped<MatchService>();
builder.Services.AddScoped<GameService>();
builder.Services.AddScoped<TournamentPrizeService>();
builder.Services.AddScoped<AwardedPrizeService>();
builder.Services.AddScoped<ProductService>();
builder.Services.AddScoped<OrderService>();
builder.Services.AddScoped<OrderItemService>();
builder.Services.AddScoped<CouponService>();
builder.Services.AddScoped<TradeListingService>();
builder.Services.AddScoped<TradeBidService>();
builder.Services.AddScoped<TradeTransactionService>();
builder.Services.AddScoped<CardPriceHistoryService>();
builder.Services.AddScoped<TradeDisputeService>();
builder.Services.AddScoped<DraftSessionService>();
builder.Services.AddScoped<DraftParticipantService>();
builder.Services.AddScoped<DraftPickService>();
builder.Services.AddScoped<ArticleService>();
builder.Services.AddScoped<ArticleTagService>();
builder.Services.AddScoped<ArticleTagAssignmentService>();
builder.Services.AddScoped<ArticleCommentService>();
builder.Services.AddScoped<StreamService>();

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    db.Database.EnsureCreated();
}

app.UseSwagger();
app.UseSwaggerUI();
app.UseCors();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
app.MapIdentityApi<ApplicationUser>();

app.Run();

public partial class Program {}
