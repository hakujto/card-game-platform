<?php

namespace Tests\Feature\Marketplace;

use App\Models\Marketplace\OrderItem;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Players\Player;
use App\Models\Marketplace\Order;
use App\Models\Marketplace\Product;

class OrderItemApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    private Player $auxPlayer;
    private Order $depOrder;
    private Product $depProduct;

    protected function setUp(): void
    {
        parent::setUp();
        $this->auxPlayer = Player::create([
            'display_name' => 'test',
            'rank' => 'Bronze',
            'rating' => 1,
            'peak_rating' => 1,
            'is_verified' => true,
            'created_at' => '2024-01-01 00:00:00',
        ]);
        $this->depOrder = Order::create([
            'status' => 'Pending',
            'total' => '0.00',
            'discount_applied' => '0.00',
            'currency' => 'xxx',
            'created_at' => '2024-01-01 00:00:00',
            'player_id' => $this->auxPlayer->id,
        ]);
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
            'order_id' => $this->depOrder->id,
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
            'order_id' => $this->depOrder->id,
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
}
