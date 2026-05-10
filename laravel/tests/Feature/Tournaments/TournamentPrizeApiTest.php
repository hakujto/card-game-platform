<?php

namespace Tests\Feature\Tournaments;

use App\Models\Tournaments\TournamentPrize;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TournamentPrizeApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    protected function setUp(): void
    {
        parent::setUp();
        $entity = TournamentPrize::create([
            'placement_from' => 1,
            'placement_to' => 1,
            'prize_type' => 'test',
            'amount' => '0.00',
            'season_points' => 1,
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/tournament_prizes');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/tournament_prizes', [
            'placement_from' => 1,
            'placement_to' => 1,
            'amount' => '0.00',
            'season_points' => 1,
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/tournament_prizes/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/tournament_prizes/{$this->entityId}", [
            'placement_from' => 1,
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/tournament_prizes/{$this->entityId}");
        $response->assertStatus(204);
    }
}
