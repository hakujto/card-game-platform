<?php

namespace Tests\Feature\Cards;

use App\Models\Cards\CardRuling;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CardRulingApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    protected function setUp(): void
    {
        parent::setUp();
        $entity = CardRuling::create([
            'ruling_text' => 'test',
            'published_at' => '2024-01-01',
            'source' => 'test',
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/card_rulings');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/card_rulings', [
            'ruling_text' => 'test',
            'published_at' => '2024-01-01',
            'source' => 'test',
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/card_rulings/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/card_rulings/{$this->entityId}", [
            'ruling_text' => 'test',
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/card_rulings/{$this->entityId}");
        $response->assertStatus(204);
    }
}
