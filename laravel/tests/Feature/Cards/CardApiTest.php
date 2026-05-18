<?php

namespace Tests\Feature\Cards;

use App\Models\Cards\Card;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Cards\CardSet;

class CardApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    private CardSet $depSet;

    protected function setUp(): void
    {
        parent::setUp();
        $this->depSet = CardSet::create([
            'name' => 'test',
            'code' => 'test',
            'release_date' => '2024-01-01',
            'set_type' => 'Core',
            'total_cards' => 1,
            'is_rotated' => true,
        ]);
        $entity = Card::create([
            'name' => 'test',
            'card_type' => 'Creature',
            'rarity' => 'Common',
            'mana_cost' => 1,
            'mana_colors' => 'White',
            'attack' => 1,
            'defense' => 1,
            'loyalty' => null,
            'description' => 'test',
            'legal_formats' => 'Standard',
            'is_banned' => false,
            'is_restricted' => false,
            'power_level' => 1,
            'set_id' => $this->depSet->id,
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/cards');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/cards', [
            'name' => 'test',
            'card_type' => 'Creature',
            'rarity' => 'Common',
            'mana_cost' => 1,
            'mana_colors' => 'White',
            'attack' => 1,
            'defense' => 1,
            'loyalty' => null,
            'description' => 'test',
            'legal_formats' => 'Standard',
            'is_banned' => false,
            'is_restricted' => false,
            'power_level' => 1,
            'set_id' => $this->depSet->id,
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/cards/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/cards/{$this->entityId}", [
            'name' => 'test',
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/cards/{$this->entityId}");
        $response->assertStatus(204);
    }

    public function test_create_fails_when_creature_requires_stats_violated(): void
    {
        // Creature card must have attack and defense
        $response = $this->postJson('/api/cards', ['name' => 'test', 'mana_colors' => 'White', 'description' => 'test', 'legal_formats' => 'Standard', 'set_id' => 1, 'card_type' => 'Creature', 'attack' => null]);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_planeswalker_requires_loyalty_violated(): void
    {
        // Planeswalker card must have loyalty
        $response = $this->postJson('/api/cards', ['name' => 'test', 'mana_colors' => 'White', 'description' => 'test', 'legal_formats' => 'Standard', 'set_id' => 1, 'card_type' => 'Planeswalker', 'loyalty' => null]);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_spell_or_artifact_no_loyalty_violated(): void
    {
        // Only Planeswalker cards can have loyalty
        $response = $this->postJson('/api/cards', ['name' => 'test', 'mana_colors' => 'White', 'description' => 'test', 'legal_formats' => 'Standard', 'set_id' => 1, 'loyalty' => 1]);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_mana_cost_range_violated(): void
    {
        // mana_cost must be between 0 and 20
        $response = $this->postJson('/api/cards', ['name' => 'test', 'mana_colors' => 'White', 'description' => 'test', 'legal_formats' => 'Standard', 'set_id' => 1, 'card_type' => 'Creature', 'attack' => 1, 'defense' => 1, 'card_type' => 'Planeswalker', 'loyalty' => 1, 'loyalty' => null, 'is_banned' => true, 'mana_cost' => 21]);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_power_level_range_violated(): void
    {
        // power_level must be between 1 and 10
        $response = $this->postJson('/api/cards', ['name' => 'test', 'mana_colors' => 'White', 'description' => 'test', 'legal_formats' => 'Standard', 'set_id' => 1, 'card_type' => 'Creature', 'attack' => 1, 'defense' => 1, 'card_type' => 'Planeswalker', 'loyalty' => 1, 'loyalty' => null, 'is_banned' => true, 'power_level' => 11]);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_not_banned_and_restricted_violated(): void
    {
        // Card cannot be both banned and restricted at the same time
        $response = $this->postJson('/api/cards', ['name' => 'test', 'mana_colors' => 'White', 'description' => 'test', 'legal_formats' => 'Standard', 'set_id' => 1, 'card_type' => 'Creature', 'attack' => 1, 'defense' => 1, 'card_type' => 'Planeswalker', 'loyalty' => 1, 'loyalty' => null, 'is_banned' => true, 'is_restricted' => true]);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_banned_card_not_in_legal_formats_violated(): void
    {
        // banned_card_not_in_legal_formats
        $response = $this->postJson('/api/cards', ['name' => 'test', 'mana_colors' => 'White', 'description' => 'test', 'legal_formats' => 'Standard', 'set_id' => 1, 'is_banned' => true]);
        $response->assertStatus(422);
    }
}
