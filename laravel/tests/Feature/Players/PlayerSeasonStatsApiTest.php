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

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/player_season_statses/{$this->entityId}");
        $response->assertStatus(200);
    }

}
