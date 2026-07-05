<?php

namespace Tests\Feature\Tournaments;

use App\Models\Tournaments\TournamentJudge;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Tournaments\Season;
use App\Models\Players\Player;
use App\Models\Tournaments\Tournament;

class TournamentJudgeApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    private Season $auxSeason;
    private Player $auxPlayer;
    private Tournament $depTournament;
    private Player $depPlayer;

    protected function setUp(): void
    {
        parent::setUp();
        $this->auxSeason = Season::create([
            'name' => 'test',
            'start_date' => '2024-01-01',
            'end_date' => '2024-01-01',
            'format' => 'Standard',
            'is_active' => true,
        ]);
        $this->auxPlayer = Player::create([
            'public_id' => '00000000-0000-0000-0000-000000000001',
            'display_name' => 'test_player_001',
            'rank' => 'Bronze',
            'rating' => 1000,
            'peak_rating' => 1,
            'is_verified' => true,
            'created_at' => '2024-01-01 00:00:00',
        ]);
        $this->depTournament = Tournament::create([
            'public_id' => '00000000-0000-0000-0000-000000000001',
            'name' => 'Test Tournament Alpha',
            'status' => 'Draft',
            'format' => 'Standard',
            'tournament_type' => 'Swiss',
            'max_players' => 8,
            'entry_fee' => 0,
            'prize_pool' => 0,
            'start_time' => '2024-01-01 00:00:00',
            'is_online' => true,
            'created_at' => '2024-01-01 00:00:00',
            'season_id' => $this->auxSeason->id,
            'organizer_id' => $this->auxPlayer->id,
        ]);
        $this->depPlayer = Player::create([
            'public_id' => '00000000-0000-0000-0000-0000000000012',
            'display_name' => 'test_player_0012',
            'rank' => 'Bronze',
            'rating' => 1000,
            'peak_rating' => 1,
            'is_verified' => true,
            'created_at' => '2024-01-01 00:00:00',
        ]);
        $entity = TournamentJudge::create([
            'role' => 'HeadJudge',
            'tournament_id' => $this->depTournament->id,
            'player_id' => $this->depPlayer->id,
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/tournament_judges');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/tournament_judges', [
            'role' => 'HeadJudge',
            'tournament_id' => $this->depTournament->id,
            'player_id' => $this->depPlayer->id,
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/tournament_judges/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/tournament_judges/{$this->entityId}");
        $response->assertStatus(204);
    }

}
