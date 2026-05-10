<?php

namespace Tests\Feature\Cards;

use App\Models\Cards\Card;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CardApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    protected function setUp(): void
    {
        parent::setUp();
        $entity = Card::create([
            'name' => 'test',
            'card_type' => 'test',
            'rarity' => 'test',
            'mana_cost' => 1,
            'mana_colors' => 'test',
            'description' => 'test',
            'legal_formats' => 'test',
            'is_banned' => true,
            'is_restricted' => true,
            'power_level' => 1,
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
            'mana_cost' => 1,
            'description' => 'test',
            'is_banned' => true,
            'is_restricted' => true,
            'power_level' => 1,
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
