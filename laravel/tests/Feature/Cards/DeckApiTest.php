<?php

namespace Tests\Feature\Cards;

use App\Models\Cards\Deck;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class DeckApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    protected function setUp(): void
    {
        parent::setUp();
        $entity = Deck::create([
            'name' => 'test',
            'format' => 'test',
            'is_public' => true,
            'is_tournament_legal' => true,
            'wins' => 1,
            'losses' => 1,
            'created_at' => '2024-01-01 00:00:00',
            'updated_at' => '2024-01-01 00:00:00',
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/decks');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/decks', [
            'name' => 'test',
            'is_public' => true,
            'is_tournament_legal' => true,
            'wins' => 1,
            'losses' => 1,
            'created_at' => '2024-01-01 00:00:00',
            'updated_at' => '2024-01-01 00:00:00',
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/decks/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/decks/{$this->entityId}", [
            'name' => 'test',
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/decks/{$this->entityId}");
        $response->assertStatus(204);
    }
}
