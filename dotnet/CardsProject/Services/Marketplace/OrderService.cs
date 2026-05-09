using CardsProject.Domain.Marketplace;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Marketplace;

public class OrderService
{
    private readonly AppDbContext _db;

    public OrderService(AppDbContext db) => _db = db;

    public System.Threading.Tasks.Task<Order> Create(Order entity)
    {
        throw new NotImplementedException();
    }

    public System.Threading.Tasks.Task<Order> Update(Order entity)
    {
        throw new NotImplementedException();
    }
}
