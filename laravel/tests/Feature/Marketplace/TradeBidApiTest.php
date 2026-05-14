<?php

namespace Tests\Feature\Marketplace;

use App\Models\Marketplace\TradeBid;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Players\Player;
use App\Models\Cards\CardSet;
use App\Models\Cards\Card;
use App\Models\Marketplace\Tradelisting;

class TradeBidApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    private Player $auxPlayer;
    private CardSet $auxCardSet;
    private Card $auxCard;
    private Tradelisting $depListing;
    private Player $depBidder;

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
        $this->auxCardSet = CardSet::create([
            'name' => 'test',
            'code' => 'test',
            'release_date' => '2024-01-01',
            'set_type' => 'Core',
            'total_cards' => 1,
        ]);
        $this->auxCard = Card::create([
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
        $this->depListing = Tradelisting::create([
            'listing_type' => 'FixedPrice',
            'foil' => true,
            'condition' => 'Mint',
            'quantity' => 1,
            'status' => 'Active',
            'created_at' => '2024-01-01 00:00:00',
            'seller_id' => $this->auxPlayer->id,
            'card_id' => $this->auxCard->id,
        ]);
        $this->depBidder = Player::create([
            'display_name' => 'test',
            'rank' => 'Bronze',
            'rating' => 1,
            'peak_rating' => 1,
            'is_verified' => true,
            'created_at' => '2024-01-01 00:00:00',
        ]);
        $entity = TradeBid::create([
            'amount' => '0.01',
            'placed_at' => '2024-01-01 00:00:00',
            'is_winning' => true,
            'listing_id' => $this->depListing->id,
            'bidder_id' => $this->depBidder->id,
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/trade_bids');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/trade_bids', [
            'amount' => '0.01',
            'placed_at' => '2024-01-01 00:00:00',
            'is_winning' => true,
            'listing_id' => $this->depListing->id,
            'bidder_id' => $this->depBidder->id,
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/trade_bids/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/trade_bids/{$this->entityId}", [
            'amount' => '0.01',
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/trade_bids/{$this->entityId}");
        $response->assertStatus(204);
    }

    public function test_create_fails_when_amount_positive_violated(): void
    {
        // Bid amount must be greater than zero
        $response = $this->postJson('/api/trade_bids', ['placed_at' => '2024-01-01 00:00:00', 'listing_id' => 1, 'bidder_id' => 1, 'amount' => 0]);
        $response->assertStatus(422);
    }
}
