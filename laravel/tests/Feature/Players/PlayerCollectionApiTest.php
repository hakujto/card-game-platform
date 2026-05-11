<?php

namespace Tests\Feature\Players;

use App\Models\Players\PlayerCollection;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Players\Player;
use App\Models\Cards\CardSet;
use App\Models\Cards\Card;

class PlayerCollectionApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    private Player $depPlayer;
    private CardSet $auxCardSet;
    private Card $depCard;

    protected function setUp(): void
    {
        parent::setUp();
        $this->depPlayer = Player::create([
            'display_name' => 'test',
            'rank' => 'Bronze',
            'rating' => 1,
            'peak_rating' => 1,
            'is_verified' => true,
            'created_at' => '2024-01-01 00:00:00',
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
        $entity = PlayerCollection::create([
            'quantity' => 1,
            'foil' => true,
            'condition' => 'Mint',
            'acquired_at' => '2024-01-01 00:00:00',
            'acquired_via' => 'Purchase',
            'player_id' => $this->depPlayer->id,
            'card_id' => $this->depCard->id,
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/player_collections');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/player_collections', [
            'quantity' => 1,
            'foil' => true,
            'condition' => 'Mint',
            'acquired_at' => '2024-01-01 00:00:00',
            'acquired_via' => 'Purchase',
            'player_id' => $this->depPlayer->id,
            'card_id' => $this->depCard->id,
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/player_collections/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/player_collections/{$this->entityId}", [
            'quantity' => 1,
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/player_collections/{$this->entityId}");
        $response->assertStatus(204);
    }
}
