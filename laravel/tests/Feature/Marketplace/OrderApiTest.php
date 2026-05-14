<?php

namespace Tests\Feature\Marketplace;

use App\Models\Marketplace\Order;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Players\Player;

class OrderApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    private Player $depPlayer;

    protected function setUp(): void
    {
        parent::setUp();
        $this->depPlayer = Player::create([
            'display_name' => 'test',
            'rank' => 'Bronze',
            'rating' => 1,
            'peak_rating' => 1,
            'is_verified' => true,
            'created_at' => '2024-01-01 00:00:00',
        ]);
        $entity = Order::create([
            'status' => 'Pending',
            'total' => '0.00',
            'discount_applied' => '0.00',
            'currency' => 'xxx',
            'tracking_number' => 'test',
            'created_at' => '2024-01-01 00:00:00',
            'paid_at' => '2024-01-01 00:00:00',
            'player_id' => $this->depPlayer->id,
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/orders');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/orders', [
            'status' => 'Pending',
            'total' => '0.00',
            'discount_applied' => '0.00',
            'currency' => 'xxx',
            'tracking_number' => 'test',
            'created_at' => '2024-01-01 00:00:00',
            'paid_at' => '2024-01-01 00:00:00',
            'player_id' => $this->depPlayer->id,
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/orders/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/orders/{$this->entityId}", [
            'total' => '0.00',
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/orders/{$this->entityId}");
        $response->assertStatus(204);
    }

    public function test_create_fails_when_paid_requires_paid_at_violated(): void
    {
        // Paid order must have paid_at set
        $response = $this->postJson('/api/orders', ['created_at' => '2024-01-01 00:00:00', 'player_id' => 1, 'status' => 'Paid', 'paid_at' => null]);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_shipped_requires_tracking_violated(): void
    {
        // Shipped order must have a tracking number
        $response = $this->postJson('/api/orders', ['created_at' => '2024-01-01 00:00:00', 'player_id' => 1, 'status' => 'Shipped', 'tracking_number' => null]);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_total_not_negative_violated(): void
    {
        // Order total must not be negative
        $response = $this->postJson('/api/orders', ['created_at' => '2024-01-01 00:00:00', 'player_id' => 1, 'status' => 'Paid', 'paid_at' => '2024-01-01 00:00:00', 'status' => 'Shipped', 'tracking_number' => 'test', 'total' => -1]);
        $response->assertStatus(422);
    }
}
