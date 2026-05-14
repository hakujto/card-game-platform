<?php

namespace Tests\Feature\Cards;

use App\Models\Cards\CardSet;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CardSetApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    protected function setUp(): void
    {
        parent::setUp();
        $entity = CardSet::create([
            'name' => 'test',
            'code' => 'test',
            'release_date' => '2024-01-01',
            'set_type' => 'Core',
            'total_cards' => 1,
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/card_sets');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/card_sets', [
            'name' => 'test',
            'code' => 'test',
            'release_date' => '2024-01-01',
            'set_type' => 'Core',
            'total_cards' => 1,
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/card_sets/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/card_sets/{$this->entityId}", [
            'name' => 'test',
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/card_sets/{$this->entityId}");
        $response->assertStatus(204);
    }

}
