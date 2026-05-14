<?php

namespace Tests\Feature\Cards;

use App\Models\Cards\DeckTag;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class DeckTagApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    protected function setUp(): void
    {
        parent::setUp();
        $entity = DeckTag::create([
            'name' => 'test',
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/deck_tags');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/deck_tags', [
            'name' => 'test',
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/deck_tags/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/deck_tags/{$this->entityId}", [
            'name' => 'test',
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/deck_tags/{$this->entityId}");
        $response->assertStatus(204);
    }

}
