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
        ]);
        $entity = Card::create([
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
            'description' => 'test',
            'legal_formats' => 'Standard',
            'is_banned' => true,
            'is_restricted' => true,
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
}
