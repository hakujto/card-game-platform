<?php

namespace Tests\Feature\Tournaments;

use App\Models\Tournaments\MatchRecord;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Players\Player;

class MatchRecordApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    private Player $depPlayer1;

    protected function setUp(): void
    {
        parent::setUp();
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
            'started_at' => '2024-01-01 00:00:00',
            'ended_at' => null,
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
            'started_at' => '2024-01-01 00:00:00',
            'ended_at' => null,
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

    public function test_create_fails_when_wins_not_negative_violated(): void
    {
        // Win counts must not be negative
        $response = $this->postJson('/api/matches', ['round_id' => 1, 'player1_id' => 1, 'status' => 'BYE', 'player2' => null, 'ended_at' => '2024-01-01 00:00:00', 'status' => 'Completed', 'started_at' => '2024-01-01 00:00:00', 'player1_wins' => -1]);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_max_three_games_violated(): void
    {
        // Win counts cannot exceed 2 in a best-of-3 match
        $response = $this->postJson('/api/matches', ['round_id' => 1, 'player1_id' => 1, 'status' => 'BYE', 'player2' => null, 'ended_at' => '2024-01-01 00:00:00', 'status' => 'Completed', 'started_at' => '2024-01-01 00:00:00', 'player1_wins' => 3]);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_bye_has_no_player2_violated(): void
    {
        // BYE match must not have a second player
        $response = $this->postJson('/api/matches', ['round_id' => 1, 'player1_id' => 1, 'status' => 'BYE', 'player2_id' => 1]);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_ended_after_started_violated(): void
    {
        // Match end time must be after start time
        $response = $this->postJson('/api/matches', ['round_id' => 1, 'player1_id' => 1, 'ended_at' => '2024-01-01 00:00:00', 'ended_at' => '2024-01-01 00:00:00']);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_completed_requires_started_at_violated(): void
    {
        // Completed match must have a start time
        $response = $this->postJson('/api/matches', ['round_id' => 1, 'player1_id' => 1, 'status' => 'Completed', 'started_at' => null]);
        $response->assertStatus(422);
    }
}
