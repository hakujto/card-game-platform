<?php

namespace Tests\Feature\Content;

use App\Models\Content\DraftParticipant;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Cards\CardSet;
use App\Models\Content\DraftSession;
use App\Models\Players\Player;

class DraftParticipantApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    private CardSet $auxCardSet;
    private DraftSession $depSession;
    private Player $depPlayer;

    protected function setUp(): void
    {
        parent::setUp();
        $this->auxCardSet = CardSet::create([
            'name' => 'test',
            'code' => 'test',
            'release_date' => '2024-01-01',
            'set_type' => 'Core',
            'total_cards' => 1,
        ]);
        $this->depSession = DraftSession::create([
            'status' => 'WaitingForPlayers',
            'draft_type' => 'Booster',
            'seats' => 1,
            'created_at' => '2024-01-01 00:00:00',
            'card_set_id' => $this->auxCardSet->id,
        ]);
        $this->depPlayer = Player::create([
            'display_name' => 'test',
            'rank' => 'Bronze',
            'rating' => 1,
            'peak_rating' => 1,
            'is_verified' => true,
            'created_at' => '2024-01-01 00:00:00',
        ]);
        $entity = DraftParticipant::create([
            'seat_number' => 1,
            'joined_at' => '2024-01-01 00:00:00',
            'session_id' => $this->depSession->id,
            'player_id' => $this->depPlayer->id,
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/draft_participants');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/draft_participants', [
            'seat_number' => 1,
            'joined_at' => '2024-01-01 00:00:00',
            'session_id' => $this->depSession->id,
            'player_id' => $this->depPlayer->id,
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/draft_participants/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/draft_participants/{$this->entityId}", [
            'seat_number' => 1,
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/draft_participants/{$this->entityId}");
        $response->assertStatus(204);
    }
}
