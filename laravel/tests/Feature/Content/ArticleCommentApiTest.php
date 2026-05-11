<?php

namespace Tests\Feature\Content;

use App\Models\Content\ArticleComment;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Players\Player;
use App\Models\Content\Article;

class ArticleCommentApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    private Player $auxPlayer;
    private Article $depArticle;
    private Player $depAuthor;

    protected function setUp(): void
    {
        parent::setUp();
        $this->auxPlayer = Player::create([
            'display_name' => 'test',
            'rank' => 'Bronze',
            'rating' => 1,
            'peak_rating' => 1,
            'is_verified' => true,
            'created_at' => '2024-01-01 00:00:00',
        ]);
        $this->depArticle = Article::create([
            'title' => 'test',
            'slug' => 'test',
            'body' => 'test',
            'status' => 'Draft',
            'article_type' => 'Guide',
            'view_count' => 1,
            'created_at' => '2024-01-01 00:00:00',
            'updated_at' => '2024-01-01 00:00:00',
            'author_id' => $this->auxPlayer->id,
        ]);
        $this->depAuthor = Player::create([
            'display_name' => 'test',
            'rank' => 'Bronze',
            'rating' => 1,
            'peak_rating' => 1,
            'is_verified' => true,
            'created_at' => '2024-01-01 00:00:00',
        ]);
        $entity = ArticleComment::create([
            'body' => 'test',
            'is_hidden' => true,
            'created_at' => '2024-01-01 00:00:00',
            'article_id' => $this->depArticle->id,
            'author_id' => $this->depAuthor->id,
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/article_comments');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/article_comments', [
            'body' => 'test',
            'is_hidden' => true,
            'created_at' => '2024-01-01 00:00:00',
            'article_id' => $this->depArticle->id,
            'author_id' => $this->depAuthor->id,
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/article_comments/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/article_comments/{$this->entityId}", [
            'body' => 'test',
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/article_comments/{$this->entityId}");
        $response->assertStatus(204);
    }
}
