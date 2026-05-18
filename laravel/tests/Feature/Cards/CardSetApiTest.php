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
            'rotation_date' => null,
            'set_type' => 'Core',
            'total_cards' => 1,
            'is_rotated' => false,
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
            'rotation_date' => null,
            'set_type' => 'Core',
            'total_cards' => 1,
            'is_rotated' => false,
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

    public function test_create_fails_when_total_cards_positive_violated(): void
    {
        // Card set must have at least one card
        $response = $this->postJson('/api/card_sets', ['name' => 'test', 'code' => 'test', 'release_date' => '2024-01-01', 'rotation_date' => '2024-01-01', 'is_rotated' => true, 'rotation_date' => '2024-01-01', 'total_cards' => 0]);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_rotation_date_after_release_violated(): void
    {
        // Rotation date must be after release date
        $response = $this->postJson('/api/card_sets', ['name' => 'test', 'code' => 'test', 'release_date' => '2024-01-01', 'total_cards' => 1, 'rotation_date' => '2024-01-01', 'rotation_date' => '2024-01-01']);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_rotated_set_has_rotation_date_violated(): void
    {
        // Rotated set must have a rotation date
        $response = $this->postJson('/api/card_sets', ['name' => 'test', 'code' => 'test', 'release_date' => '2024-01-01', 'total_cards' => 1, 'is_rotated' => true, 'rotation_date' => null]);
        $response->assertStatus(422);
    }
}
