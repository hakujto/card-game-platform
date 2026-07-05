<?php

namespace Tests\Feature\Tournaments;

use App\Models\Tournaments\TournamentRound;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Tournaments\Season;
use App\Models\Players\Player;
use App\Models\Tournaments\Tournament;

class TournamentRoundApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    private Season $auxSeason;
    private Player $auxPlayer;
    private Tournament $depTournament;

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
        $entity = TournamentRound::create([
            'round_number' => 1,
            'status' => 'Pending',
            'started_at' => '2024-01-01 00:00:00',
            'ended_at' => null,
            'time_limit_minutes' => 1,
            'tournament_id' => $this->depTournament->id,
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
            'status' => 'Pending',
            'started_at' => '2024-01-01 00:00:00',
            'ended_at' => null,
            'time_limit_minutes' => 1,
            'tournament_id' => $this->depTournament->id,
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/tournament_rounds/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_create_fails_when_ended_after_started_violated(): void
    {
        // Round end time must be after start time
        $response = $this->postJson('/api/tournament_rounds', ['round_number' => 1, 'tournament_id' => 1, 'ended_at' => '2024-01-01 00:00:00', 'ended_at' => '2024-01-01 00:00:00']);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_completed_requires_started_at_violated(): void
    {
        // Completed round must have a start time
        $response = $this->postJson('/api/tournament_rounds', ['round_number' => 1, 'tournament_id' => 1, 'status' => 'Completed', 'started_at' => null]);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_round_number_positive_violated(): void
    {
        // Round number must be greater than zero
        $response = $this->postJson('/api/tournament_rounds', ['tournament_id' => 1, 'ended_at' => '2024-01-01 00:00:00', 'status' => 'Completed', 'started_at' => '2024-01-01 00:00:00', 'round_number' => 0]);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_time_limit_positive_violated(): void
    {
        // Round time limit must be greater than zero
        $response = $this->postJson('/api/tournament_rounds', ['round_number' => 1, 'tournament_id' => 1, 'ended_at' => '2024-01-01 00:00:00', 'status' => 'Completed', 'started_at' => '2024-01-01 00:00:00', 'time_limit_minutes' => 0]);
        $response->assertStatus(422);
    }
}
