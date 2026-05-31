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
            'is_completed' => false,
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

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/player_achievements/{$this->entityId}");
        $response->assertStatus(200);
    }

}
