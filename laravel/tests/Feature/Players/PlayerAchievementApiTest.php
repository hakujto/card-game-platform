<?php

namespace Tests\Feature\Players;

use App\Models\Players\PlayerAchievement;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Players\Player;
use App\Models\Players\Achievement;

class PlayerAchievementApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    private Player $depPlayer;
    private Achievement $depAchievement;

    protected function setUp(): void
    {
        parent::setUp();
        $this->depPlayer = Player::create([
            'display_name' => 'test',
            'rank' => 'Bronze',
            'rating' => 1,
            'peak_rating' => 1,
            'is_verified' => true,
            'created_at' => '2024-01-01 00:00:00',
        ]);
        $this->depAchievement = Achievement::create([
            'name' => 'test',
            'description' => 'test',
            'points' => 1,
            'rarity' => 'Common',
            'is_hidden' => true,
        ]);
        $entity = PlayerAchievement::create([
            'earned_at' => '2024-01-01 00:00:00',
            'progress' => 1,
            'is_completed' => true,
            'player_id' => $this->depPlayer->id,
            'achievement_id' => $this->depAchievement->id,
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
            'player_id' => $this->depPlayer->id,
            'achievement_id' => $this->depAchievement->id,
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

    public function test_create_fails_when_completed_requires_progress_violated(): void
    {
        // Completed achievement must have progress greater than zero
        $response = $this->postJson('/api/player_achievements', ['earned_at' => '2024-01-01 00:00:00', 'player_id' => 1, 'achievement_id' => 1, 'is_completed' => true, 'progress' => 0]);
        $response->assertStatus(422);
    }
}
