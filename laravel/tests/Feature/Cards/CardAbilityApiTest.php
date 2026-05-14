<?php

namespace Tests\Feature\Cards;

use App\Models\Cards\CardAbility;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Cards\CardSet;
use App\Models\Cards\Card;

class CardAbilityApiTest extends TestCase
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
        $entity = CardAbility::create([
            'ability_type' => 'Keyword',
            'keyword' => 'test',
            'ability_text' => 'test',
            'card_id' => $this->depCard->id,
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/card_abilities');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/card_abilities', [
            'ability_type' => 'Keyword',
            'keyword' => 'test',
            'ability_text' => 'test',
            'card_id' => $this->depCard->id,
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/card_abilities/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/card_abilities/{$this->entityId}", [
            'keyword' => 'test',
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/card_abilities/{$this->entityId}");
        $response->assertStatus(204);
    }

    public function test_create_fails_when_keyword_ability_requires_keyword_violated(): void
    {
        // Keyword ability must have a keyword name
        $response = $this->postJson('/api/card_abilities', ['ability_text' => 'test', 'card_id' => 1, 'ability_type' => 'Keyword', 'keyword' => null]);
        $response->assertStatus(422);
    }
}
