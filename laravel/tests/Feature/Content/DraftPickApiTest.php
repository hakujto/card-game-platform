<?php

namespace Tests\Feature\Content;

use App\Models\Content\DraftPick;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Cards\CardSet;
use App\Models\Content\DraftSession;
use App\Models\Players\Player;
use App\Models\Content\DraftParticipant;
use App\Models\Cards\Card;

class DraftPickApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    private CardSet $auxCardSet;
    private DraftSession $auxDraftSession;
    private Player $auxPlayer;
    private DraftParticipant $depParticipant;
    private Card $depCard;

    protected function setUp(): void
    {
        parent::setUp();
        $this->auxCardSet = CardSet::create([
            'name' => 'test',
            'code' => 'test',
            'release_date' => '2024-01-01',
            'set_type' => 'Core',
            'total_cards' => 1,
            'is_rotated' => true,
        ]);
        $this->auxDraftSession = DraftSession::create([
            'status' => 'WaitingForPlayers',
            'draft_type' => 'Booster',
            'seats' => 1,
            'created_at' => '2024-01-01 00:00:00',
            'card_set_id' => $this->auxCardSet->id,
        ]);
        $this->auxPlayer = Player::create([
            'display_name' => 'test',
            'rank' => 'Bronze',
            'rating' => 1,
            'peak_rating' => 1,
            'is_verified' => true,
            'created_at' => '2024-01-01 00:00:00',
        ]);
        $this->depParticipant = DraftParticipant::create([
            'seat_number' => 1,
            'joined_at' => '2024-01-01 00:00:00',
            'session_id' => $this->auxDraftSession->id,
            'player_id' => $this->auxPlayer->id,
        ]);
        $this->depCard = Card::create([
            'name' => 'test',
            'card_type' => 'Creature',
            'rarity' => 'Common',
            'mana_cost' => 1,
            'mana_colors' => 'White',
            'description' => 'test',
            'legal_formats' => 'Standard',
            'is_banned' => true,
            'is_restricted' => true,
            'power_level' => 1,
            'set_id' => $this->auxCardSet->id,
        ]);
        $entity = DraftPick::create([
            'pick_number' => 1,
            'pack_number' => 1,
            'picked_at' => '2024-01-01 00:00:00',
            'participant_id' => $this->depParticipant->id,
            'card_id' => $this->depCard->id,
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/draft_picks');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/draft_picks', [
            'pick_number' => 1,
            'pack_number' => 1,
            'picked_at' => '2024-01-01 00:00:00',
            'participant_id' => $this->depParticipant->id,
            'card_id' => $this->depCard->id,
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/draft_picks/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/draft_picks/{$this->entityId}", [
            'pick_number' => 1,
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/draft_picks/{$this->entityId}");
        $response->assertStatus(204);
    }

    public function test_create_fails_when_pick_number_positive_violated(): void
    {
        // Pick number must be greater than zero
        $response = $this->postJson('/api/draft_picks', ['pack_number' => 1, 'picked_at' => '2024-01-01 00:00:00', 'participant_id' => 1, 'card_id' => 1, 'pick_number' => 0]);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_pack_number_range_violated(): void
    {
        // Pack number must be between 1 and 3
        $response = $this->postJson('/api/draft_picks', ['pick_number' => 1, 'picked_at' => '2024-01-01 00:00:00', 'participant_id' => 1, 'card_id' => 1, 'pack_number' => 4]);
        $response->assertStatus(422);
    }
}
