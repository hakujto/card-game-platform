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
    public List<Product> list(@RequestParam(required = false) String q) {
        return service.search(q);
    }

    @PostMapping
    public ResponseEntity<Product> create(@Valid @RequestBody Product entity) {
        return ResponseEntity.status(201).body(service.save(entity));
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> show(@PathVariable Long id) {
        return service.findById(id)
            .<ResponseEntity<?>>map(ResponseEntity::ok)
            .orElse(ResponseEntity.status(404).body(java.util.Map.of("error", "Product not found")));
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> update(@PathVariable Long id, @Valid @RequestBody Product entity) {
        if (service.findById(id).isEmpty()) return ResponseEntity.status(404).body(java.util.Map.of("error", "Product not found"));
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<?> patch(@PathVariable Long id, @RequestBody java.util.Map<String, Object> patch) {
        return service.findById(id).<ResponseEntity<?>>map(entity -> {
            service.applyPatch(entity, patch);
            return ResponseEntity.ok(service.save(entity));
        }).orElse(ResponseEntity.status(404).body(java.util.Map.of("error", "Product not found")));
    }


    @PostMapping("/{id}/activate")
    public ResponseEntity<Void> activate(@PathVariable Long id) {
        try {
            service.activate(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/{id}/deactivate")
    public ResponseEntity<Void> deactivate(@PathVariable Long id) {
        try {
            service.deactivate(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PatchMapping("/{id}/discount")
    public ResponseEntity<java.math.BigDecimal> applyDiscount(@PathVariable Long id, @RequestBody java.util.Map<String,Object> body) {
        try {
            return ResponseEntity.ok(service.applyDiscount(id, (Integer) body.get("percent")));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/{id}/restock")
    public ResponseEntity<Void> restock(@PathVariable Long id, @RequestBody java.util.Map<String,Object> body) {
        try {
            service.restock(id, (Integer) body.get("quantity"));
            return ResponseEntity.noContent().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/{id}/effective-price")
    public ResponseEntity<java.math.BigDecimal> effectivePrice(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.effectivePrice(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/{id}/in-stock")
    public ResponseEntity<Boolean> isInStock(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.isInStock(id));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
}
