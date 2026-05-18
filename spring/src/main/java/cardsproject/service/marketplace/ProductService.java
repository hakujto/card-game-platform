package cardsproject.service.marketplace;

import cardsproject.domain.marketplace.Product;
import cardsproject.repository.marketplace.ProductRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class ProductService {

    private final ProductRepository repository;

    public ProductService(ProductRepository repository) {
        this.repository = repository;
    }

    public List<Product> findAll() {
        return repository.findAll();
    }

    public Optional<Product> findById(Long id) {
        return repository.findById(id);
    }

    public Product save(Product entity) {
        return repository.save(entity);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }

    public void activate(Long id) {
        Product entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Product not found: " + id));
        entity.activate();
        repository.save(entity);
    }

    public void deactivate(Long id) {
        Product entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Product not found: " + id));
        entity.deactivate();
        repository.save(entity);
    }

    public java.math.BigDecimal applyDiscount(Long id, Integer percent) {
        Product entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Product not found: " + id));
        java.math.BigDecimal result = entity.applyDiscount(percent);
        repository.save(entity);
        return result;
    }

    public void restock(Long id, Integer quantity) {
        Product entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Product not found: " + id));
        entity.restock(quantity);
        repository.save(entity);
    }

    public java.math.BigDecimal effectivePrice(Long id) {
        Product entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Product not found: " + id));
        java.math.BigDecimal result = entity.effectivePrice();
        repository.save(entity);
        return result;
    }

    public Boolean isInStock(Long id) {
        Product entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Product not found: " + id));
        Boolean result = entity.isInStock();
        repository.save(entity);
        return result;
    }
}
