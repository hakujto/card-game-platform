<?php

namespace Tests\Feature\Players;

use App\Models\Players\CraftingRecipe;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CraftingRecipeApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    protected function setUp(): void
    {
        parent::setUp();
        $entity = CraftingRecipe::create([
            'dust_cost' => 1,
            'is_available' => true,
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
}
