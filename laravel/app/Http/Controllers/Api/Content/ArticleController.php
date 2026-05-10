<?php

namespace App\Http\Controllers\Api\Content;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Content\Article;
use App\Models\Players\Player;
use App\Models\Cards\Deck;

class ArticleController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json(Article::all());
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'title' => 'required|string|max:300',
            'slug' => 'required|string|max:300',
            'body' => 'required|string|max:200',
            'excerpt' => 'nullable|string|max:200',
            'cover_image_url' => 'nullable|string|url|max:200',
            'status' => 'required|string|in:Draft,Published,Archived|max:20',
            'article_type' => 'required|string|in:Guide,Tierlist,Matchup,News,Spotlight,Decklist|max:20',
            'view_count' => 'required|integer|max:200',
            'published_at' => 'nullable|date|max:200',
            'created_at' => 'required|date|max:200',
            'updated_at' => 'required|date|max:200',
            'author_id' => 'required|exists:players,id',
            'featured_deck_id' => 'nullable|exists:decks,id',
        ]);
        $item = Article::create($validated);
        return response()->json($item, 201);
    }

    public function show(Article $article): JsonResponse
    {
        return response()->json($article);
    }

    public function update(Request $request, Article $article): JsonResponse
    {
        $validated = $request->validate([
            'title' => 'sometimes|nullable|string|max:300',
            'slug' => 'sometimes|nullable|string|max:300',
            'body' => 'sometimes|nullable|string|max:200',
            'excerpt' => 'sometimes|nullable|string|max:200',
            'cover_image_url' => 'sometimes|nullable|string|url|max:200',
            'status' => 'sometimes|nullable|string|max:20',
            'article_type' => 'sometimes|nullable|string|max:20',
            'view_count' => 'sometimes|nullable|integer|max:200',
            'published_at' => 'sometimes|nullable|date|max:200',
            'created_at' => 'sometimes|nullable|date|max:200',
            'updated_at' => 'sometimes|nullable|date|max:200',
            'author_id' => 'sometimes|nullable|exists:players,id',
            'featured_deck_id' => 'sometimes|nullable|exists:decks,id',
        ]);
        $article->update($validated);
        return response()->json($article);
    }

    public function destroy(Article $article): JsonResponse
    {
        $article->delete();
        return response()->json(null, 204);
    }
}
