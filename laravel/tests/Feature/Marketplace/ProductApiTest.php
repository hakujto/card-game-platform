<?php

namespace Tests\Feature\Marketplace;

use App\Models\Marketplace\Product;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ProductApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    protected function setUp(): void
    {
        parent::setUp();
        $entity = Product::create([
            'name' => 'test',
            'product_type' => 'SingleCard',
            'price' => '0.01',
            'stock' => 1,
            'active' => true,
            'discount_percent' => 1,
            'featured' => true,
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/products');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/products', [
            'name' => 'test',
            'product_type' => 'SingleCard',
            'price' => '0.01',
            'stock' => 1,
            'active' => true,
            'discount_percent' => 1,
            'featured' => true,
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/products/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/products/{$this->entityId}", [
            'name' => 'test',
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/products/{$this->entityId}");
        $response->assertStatus(204);
    }

    public function test_create_fails_when_price_positive_violated(): void
    {
        // Product price must be greater than zero
        $response = $this->postJson('/api/products', ['name' => 'test', 'price' => 0]);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_stock_not_negative_violated(): void
    {
        // Product stock must not be negative
        $response = $this->postJson('/api/products', ['name' => 'test', 'price' => '0.00', 'stock' => -1]);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_discount_percent_range_violated(): void
    {
        // Product discount percent must be between 0 and 100
        $response = $this->postJson('/api/products', ['name' => 'test', 'price' => '0.00', 'discount_percent' => 101]);
        $response->assertStatus(422);
    }
}
