<?php

namespace Tests\Feature\Marketplace;

use App\Models\Marketplace\TradeTransaction;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TradeTransactionApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    protected function setUp(): void
    {
        parent::setUp();
        $entity = TradeTransaction::create([
            'final_price' => '0.00',
            'platform_fee' => '0.00',
            'status' => 'test',
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/trade_transactions');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/trade_transactions', [
            'final_price' => '0.00',
            'platform_fee' => '0.00',
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/trade_transactions/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/trade_transactions/{$this->entityId}", [
            'final_price' => '0.00',
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/trade_transactions/{$this->entityId}");
        $response->assertStatus(204);
    }
}
