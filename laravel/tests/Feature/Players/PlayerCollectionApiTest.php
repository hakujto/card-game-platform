<?php

namespace Tests\Feature\Players;

use App\Models\Players\PlayerCollection;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PlayerCollectionApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    protected function setUp(): void
    {
        parent::setUp();
        $entity = PlayerCollection::create([
            'quantity' => 1,
            'foil' => true,
            'condition' => 'test',
            'acquired_at' => '2024-01-01 00:00:00',
            'acquired_via' => 'test',
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/player_collections');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/player_collections', [
            'quantity' => 1,
            'foil' => true,
            'acquired_at' => '2024-01-01 00:00:00',
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/player_collections/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/player_collections/{$this->entityId}", [
            'quantity' => 1,
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/player_collections/{$this->entityId}");
        $response->assertStatus(204);
    }
}
