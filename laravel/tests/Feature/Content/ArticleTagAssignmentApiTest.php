<?php

namespace Tests\Feature\Content;

use App\Models\Content\ArticleTagAssignment;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Players\Player;
use App\Models\Content\Article;
use App\Models\Content\ArticleTag;

class ArticleTagAssignmentApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    private Player $auxPlayer;
    private Article $depArticle;
    private ArticleTag $depTag;

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
        $this->depTag = ArticleTag::create([
            'name' => 'test',
            'slug' => 'test',
        ]);
        $entity = ArticleTagAssignment::create([
            'article_id' => $this->depArticle->id,
            'tag_id' => $this->depTag->id,
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/article_tag_assignments');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/article_tag_assignments', [
            'article_id' => $this->depArticle->id,
            'tag_id' => $this->depTag->id,
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/article_tag_assignments/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/article_tag_assignments/{$this->entityId}", [

        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/article_tag_assignments/{$this->entityId}");
        $response->assertStatus(204);
    }

}
