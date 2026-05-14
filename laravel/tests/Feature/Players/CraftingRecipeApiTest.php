<?php

namespace Tests\Feature\Players;

use App\Models\Players\CraftingRecipe;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Cards\CardSet;
use App\Models\Cards\Card;

class CraftingRecipeApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    private CardSet $auxCardSet;
    private Card $depResultCard;

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
        $this->depResultCard = Card::create([
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
        $entity = CraftingRecipe::create([
            'dust_cost' => 1,
            'is_available' => true,
            'result_card_id' => $this->depResultCard->id,
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/crafting_recipes');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/crafting_recipes', [
            'dust_cost' => 1,
            'is_available' => true,
            'result_card_id' => $this->depResultCard->id,
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/crafting_recipes/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/crafting_recipes/{$this->entityId}", [
            'dust_cost' => 1,
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/crafting_recipes/{$this->entityId}");
        $response->assertStatus(204);
    }

    public function test_create_fails_when_dust_cost_positive_violated(): void
    {
        // Crafting recipe must have a dust cost greater than zero
        $response = $this->postJson('/api/crafting_recipes', ['result_card_id' => 1, 'dust_cost' => 0]);
        $response->assertStatus(422);
    }
}
