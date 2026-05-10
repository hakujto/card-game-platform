<?php

namespace Tests\Feature\Marketplace;

use App\Models\Marketplace\Tradelisting;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TradelistingApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    protected function setUp(): void
    {
        parent::setUp();
        $entity = Tradelisting::create([
            'listing_type' => 'test',
            'foil' => true,
            'condition' => 'test',
            'quantity' => 1,
            'status' => 'test',
            'created_at' => '2024-01-01 00:00:00',
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/tradelistings');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/tradelistings', [
            'foil' => true,
            'quantity' => 1,
            'created_at' => '2024-01-01 00:00:00',
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/tradelistings/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/tradelistings/{$this->entityId}", [
            'listing_type' => 'test',
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/tradelistings/{$this->entityId}");
        $response->assertStatus(204);
    }
}
