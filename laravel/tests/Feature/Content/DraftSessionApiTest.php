<?php

namespace Tests\Feature\Content;

use App\Models\Content\DraftSession;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Cards\CardSet;
use App\Models\User;

class DraftSessionApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    private CardSet $depCardSet;

    protected function setUp(): void
    {
        parent::setUp();
        $this->depCardSet = CardSet::create([
            'name' => 'test',
            'code' => 'test',
            'release_date' => '2024-01-01',
            'set_type' => 'Core',
            'total_cards' => 1,
            'is_rotated' => true,
        ]);
        $entity = DraftSession::create([
            'status' => 'Completed',
            'draft_type' => 'Booster',
            'seats' => 2,
            'time_per_pick_seconds' => 1,
            'created_at' => '2024-01-01 00:00:00',
            'completed_at' => null,
            'card_set_id' => $this->depCardSet->id,
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/draft_sessions');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/draft_sessions', [
            'status' => 'Completed',
            'draft_type' => 'Booster',
            'seats' => 2,
            'time_per_pick_seconds' => 1,
            'created_at' => '2024-01-01 00:00:00',
            'completed_at' => null,
            'card_set_id' => $this->depCardSet->id,
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/draft_sessions/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_create_fails_when_seats_range_violated(): void
    {
        // Draft session must have between 2 and 16 seats
        $response = $this->postJson('/api/draft_sessions', ['created_at' => '2024-01-01 00:00:00', 'card_set_id' => 1, 'completed_at' => '2024-01-01 00:00:00', 'status' => 'Completed', 'seats' => 17]);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_completed_at_requires_completed_status_violated(): void
    {
        // completed_at can only be set when draft status is Completed
        $response = $this->postJson('/api/draft_sessions', ['created_at' => '2024-01-01 00:00:00', 'card_set_id' => 1, 'completed_at' => '2024-01-01 00:00:00', 'status' => 'WaitingForPlayers']);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_time_per_pick_positive_violated(): void
    {
        // Time per pick must be greater than zero
        $response = $this->postJson('/api/draft_sessions', ['created_at' => '2024-01-01 00:00:00', 'card_set_id' => 1, 'completed_at' => '2024-01-01 00:00:00', 'status' => 'Completed', 'time_per_pick_seconds' => 0]);
        $response->assertStatus(422);
    }
    public function test_transition_waitingforplayers_to_drafting(): void
    {
        \DB::table('draft_sessions')->where('id', $this->entityId)->update(['status' => 'WaitingForPlayers']);
        $response = $this->patchJson("/api/draft_sessions/{$this->entityId}/transitions/waitingforplayers-to-drafting");
        $response->assertStatus(200);
    }

    public function test_transition_drafting_to_completed(): void
    {
        \DB::table('draft_sessions')->where('id', $this->entityId)->update(['status' => 'Drafting']);
        $response = $this->patchJson("/api/draft_sessions/{$this->entityId}/transitions/drafting-to-completed");
        $response->assertStatus(200);
    }

    public function test_transition_drafting_to_abandoned(): void
    {
        \DB::table('draft_sessions')->where('id', $this->entityId)->update(['status' => 'Drafting']);
        $user = User::create(['name' => 'Admin', 'email' => 'Admin@example.com', 'password' => bcrypt('password'), 'role' => 'Admin']);
        $this->actingAs($user);
        $response = $this->patchJson("/api/draft_sessions/{$this->entityId}/transitions/drafting-to-abandoned");
        $response->assertStatus(200);
    }

    public function test_transition_waitingforplayers_to_abandoned(): void
    {
        \DB::table('draft_sessions')->where('id', $this->entityId)->update(['status' => 'WaitingForPlayers']);
        $user = User::create(['name' => 'Admin', 'email' => 'Admin@example.com', 'password' => bcrypt('password'), 'role' => 'Admin']);
        $this->actingAs($user);
        $response = $this->patchJson("/api/draft_sessions/{$this->entityId}/transitions/waitingforplayers-to-abandoned");
        $response->assertStatus(200);
    }

    public function test_transition_completed_to_drafting(): void
    {
        \DB::table('draft_sessions')->where('id', $this->entityId)->update(['status' => 'Completed']);
        $response = $this->patchJson("/api/draft_sessions/{$this->entityId}/transitions/completed-to-drafting");
        $response->assertStatus(409);
    }

    public function test_transition_abandoned_to_drafting(): void
    {
        \DB::table('draft_sessions')->where('id', $this->entityId)->update(['status' => 'Abandoned']);
        $response = $this->patchJson("/api/draft_sessions/{$this->entityId}/transitions/abandoned-to-drafting");
        $response->assertStatus(409);
    }
}
