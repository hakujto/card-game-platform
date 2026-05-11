<?php

namespace Tests\Feature\Tournaments;

use App\Models\Tournaments\Season;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class SeasonApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    protected function setUp(): void
    {
        parent::setUp();
        $entity = Season::create([
            'name' => 'test',
            'start_date' => '2024-01-01',
            'end_date' => '2024-01-01',
            'format' => 'Standard',
            'is_active' => true,
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/seasons');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/seasons', [
            'name' => 'test',
            'start_date' => '2024-01-01',
            'end_date' => '2024-01-01',
            'format' => 'Standard',
            'is_active' => true,
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/seasons/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/seasons/{$this->entityId}", [
            'name' => 'test',
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/seasons/{$this->entityId}");
        $response->assertStatus(204);
    }
}
