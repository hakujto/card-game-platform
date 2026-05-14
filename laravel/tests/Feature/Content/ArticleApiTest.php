<?php

namespace Tests\Feature\Content;

use App\Models\Content\Article;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Players\Player;

class ArticleApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    private Player $depAuthor;

    protected function setUp(): void
    {
        parent::setUp();
        $this->depAuthor = Player::create([
            'display_name' => 'test',
            'rank' => 'Bronze',
            'rating' => 1,
            'peak_rating' => 1,
            'is_verified' => true,
            'created_at' => '2024-01-01 00:00:00',
        ]);
        $entity = Article::create([
            'title' => 'test',
            'slug' => 'test',
            'body' => 'test',
            'status' => 'Draft',
            'article_type' => 'Guide',
            'view_count' => 1,
            'published_at' => '2024-01-01 00:00:00',
            'created_at' => '2024-01-01 00:00:00',
            'updated_at' => '2024-01-01 00:00:00',
            'author_id' => $this->depAuthor->id,
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/articles');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/articles', [
            'title' => 'test',
            'slug' => 'test',
            'body' => 'test',
            'status' => 'Draft',
            'article_type' => 'Guide',
            'view_count' => 1,
            'published_at' => '2024-01-01 00:00:00',
            'created_at' => '2024-01-01 00:00:00',
            'updated_at' => '2024-01-01 00:00:00',
            'author_id' => $this->depAuthor->id,
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/articles/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/articles/{$this->entityId}", [
            'title' => 'test',
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/articles/{$this->entityId}");
        $response->assertStatus(204);
    }

    public function test_create_fails_when_published_requires_published_at_violated(): void
    {
        // Published article must have a published_at timestamp
        $response = $this->postJson('/api/articles', ['title' => 'test', 'slug' => 'test', 'body' => 'test', 'created_at' => '2024-01-01 00:00:00', 'updated_at' => '2024-01-01 00:00:00', 'author_id' => 1, 'status' => 'Published', 'published_at' => null]);
        $response->assertStatus(422);
    }
}
