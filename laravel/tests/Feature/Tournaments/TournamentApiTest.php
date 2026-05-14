<?php

namespace Tests\Feature\Tournaments;

use App\Models\Tournaments\Tournament;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Tournaments\Season;
use App\Models\Players\Player;

class TournamentApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    private Season $depSeason;
    private Player $depOrganizer;

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
        $this->depOrganizer = Player::create([
            'display_name' => 'test',
            'rank' => 'Bronze',
            'rating' => 1,
            'peak_rating' => 1,
            'is_verified' => true,
            'created_at' => '2024-01-01 00:00:00',
        ]);
        $entity = Tournament::create([
            'name' => 'test',
            'format' => 'Standard',
            'tournament_type' => 'Swiss',
            'status' => 'Draft',
            'max_players' => 2,
            'entry_fee' => '0.00',
            'prize_pool' => '0.00',
            'start_time' => '2024-01-01 00:00:00',
            'end_time' => null,
            'is_online' => true,
            'created_at' => '2024-01-01 00:00:00',
            'season_id' => $this->depSeason->id,
            'organizer_id' => $this->depOrganizer->id,
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/tournaments');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/tournaments', [
            'name' => 'test',
            'format' => 'Standard',
            'tournament_type' => 'Swiss',
            'status' => 'Draft',
            'max_players' => 2,
            'entry_fee' => '0.00',
            'prize_pool' => '0.00',
            'start_time' => '2024-01-01 00:00:00',
            'end_time' => null,
            'is_online' => true,
            'created_at' => '2024-01-01 00:00:00',
            'season_id' => $this->depSeason->id,
            'organizer_id' => $this->depOrganizer->id,
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/tournaments/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/tournaments/{$this->entityId}", [
            'name' => 'test',
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/tournaments/{$this->entityId}");
        $response->assertStatus(204);
    }

    public function test_create_fails_when_max_players_positive_violated(): void
    {
        // Tournament must allow between 2 and 512 players
        $response = $this->postJson('/api/tournaments', ['name' => 'test', 'start_time' => '2024-01-01 00:00:00', 'created_at' => '2024-01-01 00:00:00', 'season_id' => 1, 'organizer_id' => 1, 'end_time' => '2024-01-01 00:00:00', 'max_players' => 513]);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_entry_fee_not_negative_violated(): void
    {
        // Entry fee must not be negative
        $response = $this->postJson('/api/tournaments', ['name' => 'test', 'max_players' => 1, 'start_time' => '2024-01-01 00:00:00', 'created_at' => '2024-01-01 00:00:00', 'season_id' => 1, 'organizer_id' => 1, 'end_time' => '2024-01-01 00:00:00', 'entry_fee' => -1]);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_prize_pool_not_negative_violated(): void
    {
        // Prize pool must not be negative
        $response = $this->postJson('/api/tournaments', ['name' => 'test', 'max_players' => 1, 'start_time' => '2024-01-01 00:00:00', 'created_at' => '2024-01-01 00:00:00', 'season_id' => 1, 'organizer_id' => 1, 'end_time' => '2024-01-01 00:00:00', 'prize_pool' => -1]);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_end_time_after_start_violated(): void
    {
        // End time must be after start time
        $response = $this->postJson('/api/tournaments', ['name' => 'test', 'max_players' => 1, 'start_time' => '2024-01-01 00:00:00', 'created_at' => '2024-01-01 00:00:00', 'season_id' => 1, 'organizer_id' => 1, 'end_time' => '2024-01-01 00:00:00', 'end_time' => '2024-01-01 00:00:00']);
        $response->assertStatus(422);
    }
}
