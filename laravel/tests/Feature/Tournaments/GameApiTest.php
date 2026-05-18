<?php

namespace Tests\Feature\Tournaments;

use App\Models\Tournaments\Game;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Tournaments\Season;
use App\Models\Players\Player;
use App\Models\Tournaments\Tournament;
use App\Models\Tournaments\TournamentRound;
use App\Models\Tournaments\MatchRecord;

class GameApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    private Season $auxSeason;
    private Player $auxPlayer;
    private Tournament $auxTournament;
    private TournamentRound $auxTournamentRound;
    private MatchRecord $depMatch;

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
        $this->auxTournamentRound = TournamentRound::create([
            'round_number' => 1,
            'status' => 'Pending',
            'time_limit_minutes' => 1,
            'tournament_id' => $this->auxTournament->id,
        ]);
        $this->depMatch = MatchRecord::create([
            'status' => 'Pending',
            'player1_wins' => 1,
            'player2_wins' => 1,
            'round_id' => $this->auxTournamentRound->id,
            'player1_id' => $this->auxPlayer->id,
        ]);
        $entity = Game::create([
            'game_number' => 1,
            'winner_side' => null,
            'turns_played' => null,
            'duration_seconds' => null,
            'match_id' => $this->depMatch->id,
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/games');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/games', [
            'game_number' => 1,
            'winner_side' => null,
            'turns_played' => null,
            'duration_seconds' => null,
            'match_id' => $this->depMatch->id,
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/games/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/games/{$this->entityId}", [
            'game_number' => 1,
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/games/{$this->entityId}");
        $response->assertStatus(204);
    }

    public function test_create_fails_when_game_number_range_violated(): void
    {
        // Game number must be between 1 and 3 (best-of-3)
        $response = $this->postJson('/api/games', ['match_id' => 1, 'turns_played' => 1, 'turns_played' => 1, 'duration_seconds' => 1, 'duration_seconds' => 1, 'winner_side' => 'Draw', 'winner' => null, 'winner_side' => 'Player1', 'winner' => 'test', 'game_number' => 4]);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_turns_played_positive_violated(): void
    {
        // Turns played must be greater than zero
        $response = $this->postJson('/api/games', ['game_number' => 1, 'match_id' => 1, 'turns_played' => 1, 'turns_played' => 0]);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_duration_positive_violated(): void
    {
        // Game duration must be greater than zero
        $response = $this->postJson('/api/games', ['game_number' => 1, 'match_id' => 1, 'duration_seconds' => 1, 'duration_seconds' => 0]);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_draw_has_no_winner_violated(): void
    {
        // A draw cannot have a winner
        $response = $this->postJson('/api/games', ['game_number' => 1, 'match_id' => 1, 'winner_side' => 'Draw', 'winner_id' => 1]);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_non_draw_requires_winner_violated(): void
    {
        // A decisive game must have a winner player set
        $response = $this->postJson('/api/games', ['game_number' => 1, 'match_id' => 1, 'winner_side' => 'Player1', 'winner' => null]);
        $response->assertStatus(422);
    }
}
