<?php

namespace Tests\Feature\Tournaments;

use App\Models\Tournaments\MatchRecord;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Tournaments\Season;
use App\Models\Players\Player;
use App\Models\Tournaments\Tournament;
use App\Models\Tournaments\TournamentRound;

class MatchRecordApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    private Season $auxSeason;
    private Player $auxPlayer;
    private Tournament $auxTournament;
    private TournamentRound $depRound;
    private Player $depPlayer1;

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
            'display_name' => 'test',
            'rank' => 'Bronze',
            'rating' => 1,
            'peak_rating' => 1,
            'is_verified' => true,
            'created_at' => '2024-01-01 00:00:00',
        ]);
        $this->auxTournament = Tournament::create([
            'name' => 'test',
            'format' => 'Standard',
            'tournament_type' => 'Swiss',
            'status' => 'Draft',
            'max_players' => 1,
            'entry_fee' => '0.00',
            'prize_pool' => '0.00',
            'start_time' => '2024-01-01 00:00:00',
            'is_online' => true,
            'created_at' => '2024-01-01 00:00:00',
            'season_id' => $this->auxSeason->id,
            'organizer_id' => $this->auxPlayer->id,
        ]);
        $this->depRound = TournamentRound::create([
            'round_number' => 1,
            'status' => 'Pending',
            'time_limit_minutes' => 1,
            'tournament_id' => $this->auxTournament->id,
        ]);
        $this->depPlayer1 = Player::create([
            'display_name' => 'test',
            'rank' => 'Bronze',
            'rating' => 1,
            'peak_rating' => 1,
            'is_verified' => true,
            'created_at' => '2024-01-01 00:00:00',
        ]);
        $entity = MatchRecord::create([
            'status' => 'Pending',
            'player1_wins' => 1,
            'player2_wins' => 1,
            'round_id' => $this->depRound->id,
            'player1_id' => $this->depPlayer1->id,
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
            'status' => 'Pending',
            'player1_wins' => 1,
            'player2_wins' => 1,
            'round_id' => $this->depRound->id,
            'player1_id' => $this->depPlayer1->id,
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
