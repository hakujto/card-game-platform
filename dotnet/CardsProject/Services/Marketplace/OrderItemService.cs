using CardsProject.Domain.Marketplace;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Marketplace;

public class OrderItemService
{
    private readonly AppDbContext _db;

    public OrderItemService(AppDbContext db) => _db = db;

    public System.Threading.Tasks.Task<OrderItem> Create(OrderItem entity)
    {
        throw new NotImplementedException();
    }

    public System.Threading.Tasks.Task<OrderItem> Update(OrderItem entity)
    {
        throw new NotImplementedException();
    }
}
