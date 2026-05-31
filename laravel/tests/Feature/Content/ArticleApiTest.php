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
            'language' => 'EN',
            'view_count' => 1,
            'likes_count' => 1,
            'is_featured' => true,
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

    public function test_search_returns_200(): void
    {
        $response = $this->getJson('/api/articles?q=test');
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
            'language' => 'EN',
            'view_count' => 1,
            'likes_count' => 1,
            'is_featured' => true,
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

    public function test_create_fails_when_published_requires_published_at_violated(): void
    {
        // Published article must have a published_at timestamp
        $response = $this->postJson('/api/articles', ['title' => 'test', 'slug' => 'test', 'body' => 'test', 'created_at' => '2024-01-01 00:00:00', 'updated_at' => '2024-01-01 00:00:00', 'author_id' => 1, 'status' => 'Published', 'published_at' => null]);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_view_count_not_negative_violated(): void
    {
        // Article view count must not be negative
        $response = $this->postJson('/api/articles', ['title' => 'test', 'slug' => 'test', 'body' => 'test', 'created_at' => '2024-01-01 00:00:00', 'updated_at' => '2024-01-01 00:00:00', 'author_id' => 1, 'status' => 'Published', 'published_at' => '2024-01-01 00:00:00', 'view_count' => -1]);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_likes_count_not_negative_violated(): void
    {
        // Article likes count must not be negative
        $response = $this->postJson('/api/articles', ['title' => 'test', 'slug' => 'test', 'body' => 'test', 'created_at' => '2024-01-01 00:00:00', 'updated_at' => '2024-01-01 00:00:00', 'author_id' => 1, 'status' => 'Published', 'published_at' => '2024-01-01 00:00:00', 'likes_count' => -1]);
        $response->assertStatus(422);
    }
    public function test_transition_draft_to_published(): void
    {
        \DB::table('articles')->where('id', $this->entityId)->update(['status' => 'Draft']);
        $response = $this->patchJson("/api/articles/{$this->entityId}/transitions/draft-to-published");
        $this->assertContains($response->status(), [200, 422]);
    }

    public function test_transition_published_to_archived(): void
    {
        \DB::table('articles')->where('id', $this->entityId)->update(['status' => 'Published']);
        $response = $this->patchJson("/api/articles/{$this->entityId}/transitions/published-to-archived");
        $response->assertStatus(200);
    }

    public function test_transition_archived_to_draft(): void
    {
        \DB::table('articles')->where('id', $this->entityId)->update(['status' => 'Archived']);
        $response = $this->patchJson("/api/articles/{$this->entityId}/transitions/archived-to-draft");
        $response->assertStatus(200);
    }

    public function test_transition_published_to_draft(): void
    {
        \DB::table('articles')->where('id', $this->entityId)->update(['status' => 'Published']);
        $response = $this->patchJson("/api/articles/{$this->entityId}/transitions/published-to-draft");
        $response->assertStatus(409);
    }
}
