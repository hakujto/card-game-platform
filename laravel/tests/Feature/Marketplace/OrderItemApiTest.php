<?php

namespace Tests\Feature\Marketplace;

use App\Models\Marketplace\OrderItem;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Marketplace\Product;

class OrderItemApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    private Product $depProduct;

    protected function setUp(): void
    {
        parent::setUp();
        $this->depProduct = Product::create([
            'name' => 'test',
            'product_type' => 'SingleCard',
            'price' => '0.00',
            'stock' => 1,
            'active' => true,
            'discount_percent' => 1,
            'featured' => true,
        ]);
        $entity = OrderItem::create([
            'quantity' => 1,
            'price_at_purchase' => '0.00',
            'foil' => true,
            'product_id' => $this->depProduct->id,
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/order_items');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/order_items', [
            'quantity' => 1,
            'price_at_purchase' => '0.00',
            'foil' => true,
            'product_id' => $this->depProduct->id,
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/order_items/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/order_items/{$this->entityId}", [
            'quantity' => 1,
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/order_items/{$this->entityId}");
        $response->assertStatus(204);
    }

    public function test_create_fails_when_quantity_positive_violated(): void
    {
        // Order item quantity must be greater than zero
        $response = $this->postJson('/api/order_items', ['price_at_purchase' => '0.00', 'order_id' => 1, 'product_id' => 1, 'quantity' => 0]);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_price_not_negative_violated(): void
    {
        // Price at purchase must not be negative
        $response = $this->postJson('/api/order_items', ['quantity' => 1, 'order_id' => 1, 'product_id' => 1, 'price_at_purchase' => -1]);
        $response->assertStatus(422);
    }
}
