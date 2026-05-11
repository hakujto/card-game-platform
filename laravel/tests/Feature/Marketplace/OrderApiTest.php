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
            'created_at' => '2024-01-01 00:00:00',
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
            'created_at' => '2024-01-01 00:00:00',
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
            'status' => 'test',
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/orders/{$this->entityId}");
        $response->assertStatus(204);
    }
}
