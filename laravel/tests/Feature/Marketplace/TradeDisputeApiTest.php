<?php

namespace Tests\Feature\Marketplace;

use App\Models\Marketplace\TradeDispute;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TradeDisputeApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    protected function setUp(): void
    {
        parent::setUp();
        $entity = TradeDispute::create([
            'reason' => 'test',
            'description' => 'test',
            'status' => 'test',
            'opened_at' => '2024-01-01 00:00:00',
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/trade_disputes');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/trade_disputes', [
            'description' => 'test',
            'opened_at' => '2024-01-01 00:00:00',
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/trade_disputes/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/trade_disputes/{$this->entityId}", [
            'reason' => 'test',
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/trade_disputes/{$this->entityId}");
        $response->assertStatus(204);
    }
}
