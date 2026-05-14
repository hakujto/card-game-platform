<?php

namespace Tests\Feature\Marketplace;

use App\Models\Marketplace\TradeTransaction;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Players\Player;
use App\Models\Cards\CardSet;
use App\Models\Cards\Card;
use App\Models\Marketplace\Tradelisting;

class TradeTransactionApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    private Player $auxPlayer;
    private CardSet $auxCardSet;
    private Card $auxCard;
    private Tradelisting $depListing;
    private Player $depBuyer;
    private Player $depSeller;

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
        $this->depBuyer = Player::create([
            'display_name' => 'test',
            'rank' => 'Bronze',
            'rating' => 1,
            'peak_rating' => 1,
            'is_verified' => true,
            'created_at' => '2024-01-01 00:00:00',
        ]);
        $this->depSeller = Player::create([
            'display_name' => 'test',
            'rank' => 'Bronze',
            'rating' => 1,
            'peak_rating' => 1,
            'is_verified' => true,
            'created_at' => '2024-01-01 00:00:00',
        ]);
        $entity = TradeTransaction::create([
            'final_price' => '0.00',
            'platform_fee' => '0.00',
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

    public function test_create_returns_201(): void
    {
        $freshListing = Tradelisting::create(['listing_type' => 'FixedPrice', 'foil' => true, 'condition' => 'Mint', 'quantity' => 1, 'status' => 'Active', 'created_at' => '2024-01-01 00:00:00', 'seller_id' => $this->auxPlayer->id, 'card_id' => $this->auxCard->id]);
        $response = $this->postJson('/api/trade_transactions', [
            'final_price' => '0.00',
            'platform_fee' => '0.00',
            'status' => 'Pending',
            'completed_at' => '2024-01-01 00:00:00',
            'listing_id' => $freshListing->id,
            'buyer_id' => $this->depBuyer->id,
            'seller_id' => $this->depSeller->id,
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/trade_transactions/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/trade_transactions/{$this->entityId}", [
            'final_price' => '0.00',
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/trade_transactions/{$this->entityId}");
        $response->assertStatus(204);
    }

    public function test_create_fails_when_fee_not_negative_violated(): void
    {
        // Platform fee must not be negative
        $response = $this->postJson('/api/trade_transactions', ['final_price' => '0.00', 'listing_id' => 1, 'buyer_id' => 1, 'seller_id' => 1, 'status' => 'Completed', 'completed_at' => '2024-01-01 00:00:00', 'platform_fee' => -1]);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_completed_requires_completed_at_violated(): void
    {
        // Completed transaction must have a completed_at timestamp
        $response = $this->postJson('/api/trade_transactions', ['final_price' => '0.00', 'platform_fee' => '0.00', 'listing_id' => 1, 'buyer_id' => 1, 'seller_id' => 1, 'status' => 'Completed', 'completed_at' => null]);
        $response->assertStatus(422);
    }
}
