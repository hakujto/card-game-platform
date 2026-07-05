<?php

namespace Tests\Feature\Marketplace;

use App\Models\Marketplace\CardPriceHistory;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Cards\CardSet;
use App\Models\Cards\Card;

class CardPriceHistoryApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    private CardSet $auxCardSet;
    private Card $depCard;

    protected function setUp(): void
    {
        parent::setUp();
        $this->auxCardSet = CardSet::create([
            'name' => 'test',
            'code' => 'AA',
            'release_date' => '2024-01-01',
            'set_type' => 'Core',
            'total_cards' => 1,
            'is_rotated' => true,
        ]);
        $this->depCard = Card::create([
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
        $entity = CardPriceHistory::create([
            'price_date' => '2024-01-01',
            'avg_price' => '0.00',
            'min_price' => '0.00',
            'max_price' => '0.00',
            'volume' => 1,
            'foil' => true,
            'card_id' => $this->depCard->id,
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/card_price_histories');
        $response->assertStatus(200);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/card_price_histories/{$this->entityId}");
        $response->assertStatus(200);
    }

}
