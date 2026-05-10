<?php

namespace Tests\Feature\Tournaments;

use App\Models\Tournaments\AwardedPrize;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AwardedPrizeApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    protected function setUp(): void
    {
        parent::setUp();
        $entity = AwardedPrize::create([
            'final_placement' => 1,
            'awarded_at' => '2024-01-01 00:00:00',
            'claimed' => true,
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/awarded_prizes');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/awarded_prizes', [
            'final_placement' => 1,
            'awarded_at' => '2024-01-01 00:00:00',
            'claimed' => true,
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/awarded_prizes/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/awarded_prizes/{$this->entityId}", [
            'final_placement' => 1,
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/awarded_prizes/{$this->entityId}");
        $response->assertStatus(204);
    }
}
