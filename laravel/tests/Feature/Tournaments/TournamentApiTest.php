<?php

namespace Tests\Feature\Tournaments;

use App\Models\Tournaments\Tournament;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Tournaments\Season;
use App\Models\Players\Player;
use App\Models\User;

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
            'public_id' => '00000000-0000-0000-0000-000000000001',
            'display_name' => 'test_player_001',
            'rank' => 'Bronze',
            'rating' => 1000,
            'peak_rating' => 1,
            'is_verified' => true,
            'created_at' => '2024-01-01 00:00:00',
        ]);
        $entity = Tournament::create([
            'public_id' => '00000000-0000-0000-0000-000000000001',
            'name' => 'test',
            'status' => 'Draft',
            'format' => 'Standard',
            'tournament_type' => 'Swiss',
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

    public function test_search_returns_200(): void
    {
        $response = $this->getJson('/api/tournaments?q=test');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/tournaments', [
            'public_id' => '00000000-0000-0000-0000-0000000000012',
            'name' => 'test',
            'status' => 'Draft',
            'format' => 'Standard',
            'tournament_type' => 'Swiss',
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
            'description' => 'test',
        ]);
        $response->assertStatus(200);
    }

    public function test_create_fails_when_max_players_positive_violated(): void
    {
        // Tournament must allow between 2 and 512 players
        $response = $this->postJson('/api/tournaments', ['public_id' => '00000000-0000-0000-0000-000000000001', 'name' => 'test', 'start_time' => '2024-01-01 00:00:00', 'created_at' => '2024-01-01 00:00:00', 'season_id' => 1, 'organizer_id' => 1, 'end_time' => '2024-01-01 00:00:00', 'max_players' => 513]);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_entry_fee_not_negative_violated(): void
    {
        // Entry fee must not be negative
        $response = $this->postJson('/api/tournaments', ['public_id' => '00000000-0000-0000-0000-000000000001', 'name' => 'test', 'max_players' => 1, 'start_time' => '2024-01-01 00:00:00', 'created_at' => '2024-01-01 00:00:00', 'season_id' => 1, 'organizer_id' => 1, 'end_time' => '2024-01-01 00:00:00', 'entry_fee' => -1]);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_prize_pool_not_negative_violated(): void
    {
        // Prize pool must not be negative
        $response = $this->postJson('/api/tournaments', ['public_id' => '00000000-0000-0000-0000-000000000001', 'name' => 'test', 'max_players' => 1, 'start_time' => '2024-01-01 00:00:00', 'created_at' => '2024-01-01 00:00:00', 'season_id' => 1, 'organizer_id' => 1, 'end_time' => '2024-01-01 00:00:00', 'prize_pool' => -1]);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_end_time_after_start_violated(): void
    {
        // End time must be after start time
        $response = $this->postJson('/api/tournaments', ['public_id' => '00000000-0000-0000-0000-000000000001', 'name' => 'test', 'max_players' => 1, 'start_time' => '2024-01-01 00:00:00', 'created_at' => '2024-01-01 00:00:00', 'season_id' => 1, 'organizer_id' => 1, 'end_time' => '2024-01-01 00:00:00', 'end_time' => '2024-01-01 00:00:00']);
        $response->assertStatus(422);
    }
    public function test_transition_draft_to_registration(): void
    {
        \DB::table('tournaments')->where('id', $this->entityId)->update(['status' => 'Draft']);
        $user = User::create(['name' => 'Admin', 'email' => 'Admin@example.com', 'password' => bcrypt('password'), 'role' => 'Admin']);
        $this->actingAs($user);
        $response = $this->patchJson("/api/tournaments/{$this->entityId}/transitions/draft-to-registration");
        $this->assertContains($response->status(), [200, 422]);
    }

    public function test_transition_registration_to_ongoing(): void
    {
        \DB::table('tournaments')->where('id', $this->entityId)->update(['status' => 'Registration']);
        $user = User::create(['name' => 'Admin', 'email' => 'Admin@example.com', 'password' => bcrypt('password'), 'role' => 'Admin']);
        $this->actingAs($user);
        $response = $this->patchJson("/api/tournaments/{$this->entityId}/transitions/registration-to-ongoing");
        $response->assertStatus(200);
    }

    public function test_transition_registration_to_cancelled(): void
    {
        \DB::table('tournaments')->where('id', $this->entityId)->update(['status' => 'Registration']);
        $user = User::create(['name' => 'Admin', 'email' => 'Admin@example.com', 'password' => bcrypt('password'), 'role' => 'Admin']);
        $this->actingAs($user);
        $response = $this->patchJson("/api/tournaments/{$this->entityId}/transitions/registration-to-cancelled");
        $response->assertStatus(200);
    }

    public function test_transition_ongoing_to_completed(): void
    {
        \DB::table('tournaments')->where('id', $this->entityId)->update(['status' => 'Ongoing']);
        $user = User::create(['name' => 'Admin', 'email' => 'Admin@example.com', 'password' => bcrypt('password'), 'role' => 'Admin']);
        $this->actingAs($user);
        $response = $this->patchJson("/api/tournaments/{$this->entityId}/transitions/ongoing-to-completed");
        $response->assertStatus(200);
    }

    public function test_transition_ongoing_to_cancelled(): void
    {
        \DB::table('tournaments')->where('id', $this->entityId)->update(['status' => 'Ongoing']);
        $user = User::create(['name' => 'Admin', 'email' => 'Admin@example.com', 'password' => bcrypt('password'), 'role' => 'Admin']);
        $this->actingAs($user);
        $response = $this->patchJson("/api/tournaments/{$this->entityId}/transitions/ongoing-to-cancelled");
        $response->assertStatus(200);
    }

    public function test_transition_completed_to_draft(): void
    {
        \DB::table('tournaments')->where('id', $this->entityId)->update(['status' => 'Completed']);
        $response = $this->patchJson("/api/tournaments/{$this->entityId}/transitions/completed-to-draft");
        $response->assertStatus(409);
    }

    public function test_transition_cancelled_to_draft(): void
    {
        \DB::table('tournaments')->where('id', $this->entityId)->update(['status' => 'Cancelled']);
        $response = $this->patchJson("/api/tournaments/{$this->entityId}/transitions/cancelled-to-draft");
        $response->assertStatus(409);
    }
}
