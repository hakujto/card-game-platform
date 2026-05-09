using CardsProject.Domain.Marketplace;
using CardsProject.Infrastructure;

namespace CardsProject.Services.Marketplace;

public class ProductService
{
    private readonly AppDbContext _db;

    public ProductService(AppDbContext db) => _db = db;

    public System.Threading.Tasks.Task<Product> Create(Product entity)
    {
        throw new NotImplementedException();
    }

    public System.Threading.Tasks.Task<Product> Update(Product entity)
    {
        throw new NotImplementedException();
    }
}
