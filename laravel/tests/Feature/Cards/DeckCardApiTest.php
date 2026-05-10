<?php

namespace Tests\Feature\Cards;

use App\Models\Cards\DeckCard;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class DeckCardApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    protected function setUp(): void
    {
        parent::setUp();
        $entity = DeckCard::create([
            'quantity' => 1,
            'is_commander' => true,
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/deck_cards');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/deck_cards', [
            'quantity' => 1,
            'is_commander' => true,
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/deck_cards/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/deck_cards/{$this->entityId}", [
            'quantity' => 1,
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/deck_cards/{$this->entityId}");
        $response->assertStatus(204);
    }
}
