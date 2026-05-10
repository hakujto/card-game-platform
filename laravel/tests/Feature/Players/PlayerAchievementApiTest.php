<?php

namespace Tests\Feature\Players;

use App\Models\Players\PlayerAchievement;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PlayerAchievementApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    protected function setUp(): void
    {
        parent::setUp();
        $entity = PlayerAchievement::create([
            'earned_at' => '2024-01-01 00:00:00',
            'progress' => 1,
            'is_completed' => true,
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/player_achievements');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/player_achievements', [
            'earned_at' => '2024-01-01 00:00:00',
            'progress' => 1,
            'is_completed' => true,
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/player_achievements/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/player_achievements/{$this->entityId}", [
            'earned_at' => '2024-01-01 00:00:00',
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/player_achievements/{$this->entityId}");
        $response->assertStatus(204);
    }
}
