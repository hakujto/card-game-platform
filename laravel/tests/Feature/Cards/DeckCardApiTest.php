<?php

namespace Tests\Feature\Cards;

use App\Models\Cards\DeckCard;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Players\Player;
use App\Models\Cards\Deck;
use App\Models\Cards\CardSet;
use App\Models\Cards\Card;

class DeckCardApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    private Player $auxPlayer;
    private Deck $depDeck;
    private CardSet $auxCardSet;
    private Card $depCard;

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
        $this->auxCardSet = CardSet::create([
            'name' => 'test',
            'code' => 'test',
            'release_date' => '2024-01-01',
            'set_type' => 'Core',
            'total_cards' => 1,
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
        $entity = DeckCard::create([
            'quantity' => 1,
            'is_commander' => true,
            'deck_id' => $this->depDeck->id,
            'card_id' => $this->depCard->id,
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/deck_cards');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/deck_cards', [
            'quantity' => 1,
            'is_commander' => true,
            'deck_id' => $this->depDeck->id,
            'card_id' => $this->depCard->id,
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/deck_cards/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/deck_cards/{$this->entityId}", [
            'quantity' => 1,
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/deck_cards/{$this->entityId}");
        $response->assertStatus(204);
    }

    public function test_create_fails_when_quantity_range_violated(): void
    {
        // A deck can contain between 1 and 4 copies of a card
        $response = $this->postJson('/api/deck_cards', ['deck_id' => 1, 'card_id' => 1, 'quantity' => 5]);
        $response->assertStatus(422);
    }
}
