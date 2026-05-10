<?php

namespace Tests\Feature\Marketplace;

use App\Models\Marketplace\CardPriceHistory;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CardPriceHistoryApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    protected function setUp(): void
    {
        parent::setUp();
        $entity = CardPriceHistory::create([
            'price_date' => '2024-01-01',
            'avg_price' => '0.00',
            'min_price' => '0.00',
            'max_price' => '0.00',
            'volume' => 1,
            'foil' => true,
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/card_price_histories');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/card_price_histories', [
            'price_date' => '2024-01-01',
            'avg_price' => '0.00',
            'min_price' => '0.00',
            'max_price' => '0.00',
            'volume' => 1,
            'foil' => true,
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/card_price_histories/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/card_price_histories/{$this->entityId}", [
            'price_date' => '2024-01-01',
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/card_price_histories/{$this->entityId}");
        $response->assertStatus(204);
    }
}
