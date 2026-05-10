<?php

namespace Tests\Feature\Marketplace;

use App\Models\Marketplace\TradeBid;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TradeBidApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    protected function setUp(): void
    {
        parent::setUp();
        $entity = TradeBid::create([
            'amount' => '0.00',
            'placed_at' => '2024-01-01 00:00:00',
            'is_winning' => true,
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/trade_bids');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/trade_bids', [
            'amount' => '0.00',
            'placed_at' => '2024-01-01 00:00:00',
            'is_winning' => true,
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/trade_bids/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/trade_bids/{$this->entityId}", [
            'amount' => '0.00',
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/trade_bids/{$this->entityId}");
        $response->assertStatus(204);
    }
}
