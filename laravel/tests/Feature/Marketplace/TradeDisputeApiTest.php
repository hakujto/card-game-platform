<?php

namespace Tests\Feature\Marketplace;

use App\Models\Marketplace\TradeDispute;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Players\Player;
use App\Models\Cards\CardSet;
use App\Models\Cards\Card;
use App\Models\Marketplace\TradeListing;
use App\Models\Marketplace\TradeTransaction;

class TradeDisputeApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    private Player $auxPlayer;
    private CardSet $auxCardSet;
    private Card $auxCard;
    private TradeListing $auxTradeListing;
    private TradeTransaction $depTransaction;
    private Player $depOpenedBy;

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
            'is_rotated' => true,
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
        $this->auxTradeListing = TradeListing::create([
            'status' => 'Active',
            'listing_type' => 'FixedPrice',
            'foil' => true,
            'condition' => 'Mint',
            'quantity' => 1,
            'created_at' => '2024-01-01 00:00:00',
            'seller_id' => $this->auxPlayer->id,
            'card_id' => $this->auxCard->id,
        ]);
        $this->depTransaction = TradeTransaction::create([
            'final_price' => '0.00',
            'platform_fee' => '0.00',
            'status' => 'Pending',
            'listing_id' => $this->auxTradeListing->id,
            'buyer_id' => $this->auxPlayer->id,
            'seller_id' => $this->auxPlayer->id,
        ]);
        $this->depOpenedBy = Player::create([
            'display_name' => 'test',
            'rank' => 'Bronze',
            'rating' => 1,
            'peak_rating' => 1,
            'is_verified' => true,
            'created_at' => '2024-01-01 00:00:00',
        ]);
        $entity = TradeDispute::create([
            'status' => 'Resolved',
            'reason' => 'ItemNotReceived',
            'description' => 'test',
            'opened_at' => '2024-01-01 00:00:00',
            'resolved_at' => null,
            'transaction_id' => $this->depTransaction->id,
            'opened_by_id' => $this->depOpenedBy->id,
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/trade_disputes');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $freshSubListing = TradeListing::create(['status' => 'Active', 'listing_type' => 'FixedPrice', 'foil' => true, 'condition' => 'Mint', 'quantity' => 1, 'created_at' => '2024-01-01 00:00:00', 'seller_id' => $this->auxPlayer->id, 'card_id' => $this->auxCard->id]);
        $freshTransaction = TradeTransaction::create(['final_price' => '0.00', 'platform_fee' => '0.00', 'status' => 'Pending', 'listing_id' => $freshSubListing->id, 'buyer_id' => $this->auxPlayer->id, 'seller_id' => $this->auxPlayer->id]);
        $response = $this->postJson('/api/trade_disputes', [
            'status' => 'Resolved',
            'reason' => 'ItemNotReceived',
            'description' => 'test',
            'opened_at' => '2024-01-01 00:00:00',
            'resolved_at' => null,
            'transaction_id' => $freshTransaction->id,
            'opened_by_id' => $this->depOpenedBy->id,
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/trade_disputes/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_create_fails_when_resolved_at_requires_terminal_status_violated(): void
    {
        // resolved_at_requires_terminal_status
        $response = $this->postJson('/api/trade_disputes', ['reason' => 'ItemNotReceived', 'description' => 'test', 'opened_at' => '2024-01-01 00:00:00', 'transaction_id' => 1, 'opened_by_id' => 1, 'resolved_at' => '2024-01-01 00:00:00', 'status' => 'Open']);
        $response->assertStatus(422);
    }
    public function test_transition_open_to_underreview(): void
    {
        \DB::table('trade_disputes')->where('id', $this->entityId)->update(['status' => 'Open']);
        $response = $this->patchJson("/api/trade_disputes/{$this->entityId}/transitions/open-to-underreview");
        $response->assertStatus(200);
    }

    public function test_transition_underreview_to_resolved(): void
    {
        \DB::table('trade_disputes')->where('id', $this->entityId)->update(['status' => 'UnderReview']);
        $response = $this->patchJson("/api/trade_disputes/{$this->entityId}/transitions/underreview-to-resolved");
        $this->assertContains($response->status(), [200, 422]);
    }

    public function test_transition_underreview_to_resolved_fails_when_resolution_null(): void
    {
        \DB::table('trade_disputes')->where('id', $this->entityId)->update(['status' => 'UnderReview', 'resolution' => null]);
        $response = $this->patchJson("/api/trade_disputes/{$this->entityId}/transitions/underreview-to-resolved");
        $response->assertStatus(422);
    }

    public function test_transition_underreview_to_escalated(): void
    {
        \DB::table('trade_disputes')->where('id', $this->entityId)->update(['status' => 'UnderReview']);
        $response = $this->patchJson("/api/trade_disputes/{$this->entityId}/transitions/underreview-to-escalated");
        $response->assertStatus(200);
    }

    public function test_transition_escalated_to_resolved(): void
    {
        \DB::table('trade_disputes')->where('id', $this->entityId)->update(['status' => 'Escalated']);
        $response = $this->patchJson("/api/trade_disputes/{$this->entityId}/transitions/escalated-to-resolved");
        $this->assertContains($response->status(), [200, 422]);
    }

    public function test_transition_escalated_to_resolved_fails_when_resolution_null(): void
    {
        \DB::table('trade_disputes')->where('id', $this->entityId)->update(['status' => 'Escalated', 'resolution' => null]);
        $response = $this->patchJson("/api/trade_disputes/{$this->entityId}/transitions/escalated-to-resolved");
        $response->assertStatus(422);
    }

    public function test_transition_resolved_to_open(): void
    {
        \DB::table('trade_disputes')->where('id', $this->entityId)->update(['status' => 'Resolved']);
        $response = $this->patchJson("/api/trade_disputes/{$this->entityId}/transitions/resolved-to-open");
        $response->assertStatus(409);
    }
}
