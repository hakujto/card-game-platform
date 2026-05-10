<?php

namespace Tests\Feature\Players;

use App\Models\Players\CraftingIngredient;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CraftingIngredientApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    protected function setUp(): void
    {
        parent::setUp();
        $entity = CraftingIngredient::create([
            'quantity' => 1,
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/crafting_ingredients');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/crafting_ingredients', [
            'quantity' => 1,
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/crafting_ingredients/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/crafting_ingredients/{$this->entityId}", [
            'quantity' => 1,
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/crafting_ingredients/{$this->entityId}");
        $response->assertStatus(204);
    }
}
