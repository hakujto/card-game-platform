<?php

namespace Tests\Feature\Players;

use App\Models\Players\Friendship;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Players\Player;

class FriendshipApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    private Player $depRequester;
    private Player $depReceiver;

    protected function setUp(): void
    {
        parent::setUp();
        $this->depRequester = Player::create([
            'display_name' => 'test',
            'rank' => 'Bronze',
            'rating' => 1,
            'peak_rating' => 1,
            'is_verified' => true,
            'created_at' => '2024-01-01 00:00:00',
        ]);
        $this->depReceiver = Player::create([
            'display_name' => 'test',
            'rank' => 'Bronze',
            'rating' => 1,
            'peak_rating' => 1,
            'is_verified' => true,
            'created_at' => '2024-01-01 00:00:00',
        ]);
        $entity = Friendship::create([
            'status' => 'Pending',
            'created_at' => '2024-01-01 00:00:00',
            'requester_id' => $this->depRequester->id,
            'receiver_id' => $this->depReceiver->id,
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/friendships');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/friendships', [
            'status' => 'Pending',
            'created_at' => '2024-01-01 00:00:00',
            'requester_id' => $this->depRequester->id,
            'receiver_id' => $this->depReceiver->id,
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/friendships/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/friendships/{$this->entityId}", [
            'created_at' => '2024-01-01 00:00:00',
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/friendships/{$this->entityId}");
        $response->assertStatus(204);
    }

}
