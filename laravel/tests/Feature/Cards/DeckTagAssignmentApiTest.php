<?php

namespace Tests\Feature\Cards;

use App\Models\Cards\DeckTagAssignment;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Players\Player;
use App\Models\Cards\Deck;
use App\Models\Cards\DeckTag;

class DeckTagAssignmentApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    private Player $auxPlayer;
    private Deck $depDeck;
    private DeckTag $depTag;

    protected function setUp(): void
    {
        parent::setUp();
        $this->auxPlayer = Player::create([
            'display_name' => 'test',
            'rank' => 'Bronze',
            'rating' => 1,
            'peak_rating' => 1,
            'is_verified' => true,
            'created_at' => '2024-01-01 00:00:00',
        ]);
        $this->depDeck = Deck::create([
            'name' => 'test',
            'format' => 'Standard',
            'is_public' => true,
            'is_tournament_legal' => true,
            'wins' => 1,
            'losses' => 1,
            'created_at' => '2024-01-01 00:00:00',
            'updated_at' => '2024-01-01 00:00:00',
            'player_id' => $this->auxPlayer->id,
        ]);
        $this->depTag = DeckTag::create([
            'name' => 'test',
        ]);
        $entity = DeckTagAssignment::create([
            'deck_id' => $this->depDeck->id,
            'tag_id' => $this->depTag->id,
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/deck_tag_assignments');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/deck_tag_assignments', [
            'deck_id' => $this->depDeck->id,
            'tag_id' => $this->depTag->id,
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/deck_tag_assignments/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/deck_tag_assignments/{$this->entityId}", [

        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/deck_tag_assignments/{$this->entityId}");
        $response->assertStatus(204);
    }
}
