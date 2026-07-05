<?php

namespace Tests\Feature\Marketplace;

use App\Models\Marketplace\TradeTransaction;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Players\Player;
use App\Models\Cards\CardSet;
use App\Models\Cards\Card;
use App\Models\Marketplace\TradeListing;

class TradeTransactionApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    private Player $auxPlayer;
    private CardSet $auxCardSet;
    private Card $auxCard;
    private TradeListing $depListing;
    private Player $depBuyer;
    private Player $depSeller;

    protected function setUp(): void
    {
        parent::setUp();
        $this->auxPlayer = Player::create([
            'public_id' => '00000000-0000-0000-0000-000000000001',
            'display_name' => 'test_player_001',
            'rank' => 'Bronze',
            'rating' => 1000,
            'peak_rating' => 1,
            'is_verified' => true,
            'created_at' => '2024-01-01 00:00:00',
        ]);
        $this->auxCardSet = CardSet::create([
            'name' => 'test',
            'code' => 'AA',
            'release_date' => '2024-01-01',
            'set_type' => 'Core',
            'total_cards' => 1,
            'is_rotated' => true,
        ]);
        $this->auxCard = Card::create([
            'public_id' => '00000000-0000-0000-0000-000000000001',
            'name' => 'Test Lightning Bolt',
            'card_type' => 'Spell',
            'rarity' => 'Common',
            'mana_cost' => 1,
            'mana_colors' => 'White',
            'description' => 'test',
            'legal_formats' => 'Standard',
            'is_banned' => true,
            'is_restricted' => true,
            'power_level' => 3,
            'total_copies_in_circulation' => 1,
            'set_id' => $this->auxCardSet->id,
        ]);
        $this->depListing = TradeListing::create([
            'public_id' => '00000000-0000-0000-0000-000000000001',
            'status' => 'Active',
            'listing_type' => 'FixedPrice',
            'foil' => true,
            'condition' => 'Mint',
            'quantity' => 1,
            'created_at' => '2024-01-01 00:00:00',
            'seller_id' => $this->auxPlayer->id,
            'card_id' => $this->auxCard->id,
        ]);
        $this->depBuyer = Player::create([
            'public_id' => '00000000-0000-0000-0000-0000000000012',
            'display_name' => 'test_player_0012',
            'rank' => 'Bronze',
            'rating' => 1000,
            'peak_rating' => 1,
            'is_verified' => true,
            'created_at' => '2024-01-01 00:00:00',
        ]);
        $this->depSeller = Player::create([
            'public_id' => '00000000-0000-0000-0000-0000000000013',
            'display_name' => 'test_player_0013',
            'rank' => 'Bronze',
            'rating' => 1000,
            'peak_rating' => 1,
            'is_verified' => true,
            'created_at' => '2024-01-01 00:00:00',
        ]);
        $entity = TradeTransaction::create([
            'final_price' => '0.01',
            'platform_fee' => '0.01',
            'status' => 'Pending',
            'completed_at' => '2024-01-01 00:00:00',
            'listing_id' => $this->depListing->id,
            'buyer_id' => $this->depBuyer->id,
            'seller_id' => $this->depSeller->id,
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/trade_transactions');
        $response->assertStatus(200);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/trade_transactions/{$this->entityId}");
        $response->assertStatus(200);
    }

}
