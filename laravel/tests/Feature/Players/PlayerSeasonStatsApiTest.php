<?php

namespace Tests\Feature\Players;

use App\Models\Players\PlayerSeasonStats;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Tournaments\Season;

class PlayerSeasonStatsApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    private Season $depSeason;

    protected function setUp(): void
    {
        parent::setUp();
        $this->depSeason = Season::create([
            'name' => 'test',
            'start_date' => '2024-01-01',
            'end_date' => '2024-01-01',
            'format' => 'Standard',
            'is_active' => true,
        ]);
        $entity = PlayerSeasonStats::create([
            'wins' => 1,
            'losses' => 1,
            'draws' => 1,
            'tournament_wins' => 1,
            'season_points' => 1,
            'season_id' => $this->depSeason->id,
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/player_season_statses');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/player_season_statses', [
            'wins' => 1,
            'losses' => 1,
            'draws' => 1,
            'tournament_wins' => 1,
            'season_points' => 1,
            'season_id' => $this->depSeason->id,
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/player_season_statses/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/player_season_statses/{$this->entityId}", [
            'wins' => 1,
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/player_season_statses/{$this->entityId}");
        $response->assertStatus(204);
    }

}
