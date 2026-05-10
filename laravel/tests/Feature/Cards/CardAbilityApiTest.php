<?php

namespace Tests\Feature\Cards;

use App\Models\Cards\CardAbility;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CardAbilityApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    protected function setUp(): void
    {
        parent::setUp();
        $entity = CardAbility::create([
            'ability_type' => 'test',
            'ability_text' => 'test',
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
            'ability_text' => 'test',
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
            'ability_type' => 'test',
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/card_abilities/{$this->entityId}");
        $response->assertStatus(204);
    }
}
