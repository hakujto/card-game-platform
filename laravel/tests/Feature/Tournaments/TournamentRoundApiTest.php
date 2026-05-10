<?php

namespace Tests\Feature\Tournaments;

use App\Models\Tournaments\TournamentRound;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TournamentRoundApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    protected function setUp(): void
    {
        parent::setUp();
        $entity = TournamentRound::create([
            'round_number' => 1,
            'status' => 'test',
            'time_limit_minutes' => 1,
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/tournament_rounds');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/tournament_rounds', [
            'round_number' => 1,
            'time_limit_minutes' => 1,
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/tournament_rounds/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/tournament_rounds/{$this->entityId}", [
            'round_number' => 1,
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/tournament_rounds/{$this->entityId}");
        $response->assertStatus(204);
    }
}
