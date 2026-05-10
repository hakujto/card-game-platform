<?php

namespace Tests\Feature\Tournaments;

use App\Models\Tournaments\MatchRecord;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class MatchRecordApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    protected function setUp(): void
    {
        parent::setUp();
        $entity = MatchRecord::create([
            'status' => 'test',
            'player1_wins' => 1,
            'player2_wins' => 1,
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/matches');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/matches', [
            'player1_wins' => 1,
            'player2_wins' => 1,
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/matches/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/matches/{$this->entityId}", [
            'table_number' => 1,
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/matches/{$this->entityId}");
        $response->assertStatus(204);
    }
}
