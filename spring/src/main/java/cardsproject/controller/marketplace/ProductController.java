package cardsproject.controller.marketplace;

import cardsproject.domain.marketplace.Product;
import cardsproject.service.marketplace.ProductService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/products")
public class ProductController {

    private final ProductService service;

    public ProductController(ProductService service) {
        this.service = service;
    }

    @GetMapping
    public List<Product> list() {
        return service.findAll();
    }

    @PostMapping
    public ResponseEntity<Product> create(@Valid @RequestBody Product entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Product> show(@PathVariable Long id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<Product> update(@PathVariable Long id, @Valid @RequestBody Product entity) {
        if (service.findById(id).isEmpty()) return ResponseEntity.notFound().build();
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<Product> patch(@PathVariable Long id, @Valid @RequestBody Product entity) {
        if (service.findById(id).isEmpty()) return ResponseEntity.notFound().build();
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        if (service.findById(id).isEmpty()) return ResponseEntity.notFound().build();
        service.delete(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/activate")
    public ResponseEntity<Void> activate(@PathVariable Long id) {
        service.activate(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/deactivate")
    public ResponseEntity<Void> deactivate(@PathVariable Long id) {
        service.deactivate(id);
        return ResponseEntity.noContent().build();
    }

    @PatchMapping("/{id}/discount")
    public ResponseEntity<java.math.BigDecimal> applyDiscount(@PathVariable Long id, @RequestBody java.util.Map<String,Object> body) {
        return ResponseEntity.ok(service.applyDiscount(id, (Integer) body.get("percent")));
    }

    @PostMapping("/{id}/restock")
    public ResponseEntity<Void> restock(@PathVariable Long id, @RequestBody java.util.Map<String,Object> body) {
        service.restock(id, (Integer) body.get("quantity"));
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{id}/effective-price")
    public ResponseEntity<java.math.BigDecimal> effectivePrice(@PathVariable Long id) {
        return ResponseEntity.ok(service.effectivePrice(id));
    }

    @GetMapping("/{id}/in-stock")
    public ResponseEntity<Boolean> isInStock(@PathVariable Long id) {
        return ResponseEntity.ok(service.isInStock(id));
    }
}
