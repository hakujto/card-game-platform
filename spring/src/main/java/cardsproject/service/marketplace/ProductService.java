package cardsproject.service.marketplace;

import cardsproject.domain.marketplace.Product;
import cardsproject.repository.marketplace.ProductRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import cardsproject.domain.marketplace.ProductProductTypeType;

@Service
public class ProductService {

    private final ProductRepository repository;

    public ProductService(ProductRepository repository) {
        this.repository = repository;
    }

    public List<Product> findAll() {
        return repository.findAll();
    }

    public List<Product> search(String q) {
        if (q == null || q.isBlank()) return repository.findAll();
        return repository.findAll().stream()
            .filter(e -> (e.getName() != null && e.getName().toLowerCase().contains(q.toLowerCase())) || (e.getDescription() != null && e.getDescription().toLowerCase().contains(q.toLowerCase())))
            .collect(java.util.stream.Collectors.toList());
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

    public void applyPatch(Product entity, java.util.Map<String, Object> patch) {
        if (patch.containsKey("name") && patch.get("name") != null) entity.setName(patch.get("name").toString());
        if (patch.containsKey("productType")) entity.setProductType(ProductProductTypeType.valueOf(patch.get("productType").toString()));
        if (patch.containsKey("price") && patch.get("price") != null) entity.setPrice(new java.math.BigDecimal(patch.get("price").toString()));
        if (patch.containsKey("stock") && patch.get("stock") != null) entity.setStock(Integer.valueOf(patch.get("stock").toString()));
        if (patch.containsKey("active") && patch.get("active") != null) entity.setActive(Boolean.valueOf(patch.get("active").toString()));
        if (patch.containsKey("discountPercent") && patch.get("discountPercent") != null) entity.setDiscountPercent(Integer.valueOf(patch.get("discountPercent").toString()));
        if (patch.containsKey("description") && patch.get("description") != null) entity.setDescription(patch.get("description").toString());
        if (patch.containsKey("imageUrl") && patch.get("imageUrl") != null) entity.setImageUrl(patch.get("imageUrl").toString());
        if (patch.containsKey("featured") && patch.get("featured") != null) entity.setFeatured(Boolean.valueOf(patch.get("featured").toString()));
        if (patch.containsKey("cardId") && patch.get("cardId") != null) entity.setCardId(Long.valueOf(patch.get("cardId").toString()));
        if (patch.containsKey("cardSetId") && patch.get("cardSetId") != null) entity.setCardSetId(Long.valueOf(patch.get("cardSetId").toString()));
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
