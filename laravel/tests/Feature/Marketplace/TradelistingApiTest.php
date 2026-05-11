<?php

namespace Tests\Feature\Marketplace;

use App\Models\Marketplace\Tradelisting;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Players\Player;
use App\Models\Cards\CardSet;
use App\Models\Cards\Card;

class TradelistingApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    private Player $depSeller;
    private CardSet $auxCardSet;
    private Card $depCard;

    protected function setUp(): void
    {
        parent::setUp();
        $this->depSeller = Player::create([
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
        $entity = Tradelisting::create([
            'listing_type' => 'FixedPrice',
            'foil' => true,
            'condition' => 'Mint',
            'quantity' => 1,
            'status' => 'Active',
            'created_at' => '2024-01-01 00:00:00',
            'seller_id' => $this->depSeller->id,
            'card_id' => $this->depCard->id,
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/tradelistings');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/tradelistings', [
            'listing_type' => 'FixedPrice',
            'foil' => true,
            'condition' => 'Mint',
            'quantity' => 1,
            'status' => 'Active',
            'created_at' => '2024-01-01 00:00:00',
            'seller_id' => $this->depSeller->id,
            'card_id' => $this->depCard->id,
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/tradelistings/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/tradelistings/{$this->entityId}", [
            'listing_type' => 'test',
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/tradelistings/{$this->entityId}");
        $response->assertStatus(204);
    }
}
