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
            'view_count' => 'required|integer',
            'published_at' => 'nullable|date',
            'created_at' => 'required|date',
            'updated_at' => 'required|date',
            'author_id' => 'required|exists:players,id',
            'featured_deck_id' => 'nullable|exists:decks,id',
        ]);
        $item = Article::create($validated);
        $item->validateRules();
        try {
            $item->validateImplies();
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 422);
        }

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
            'view_count' => 'sometimes|nullable|integer',
            'published_at' => 'sometimes|nullable|date',
            'created_at' => 'sometimes|nullable|date',
            'updated_at' => 'sometimes|nullable|date',
            'author_id' => 'sometimes|nullable|exists:players,id',
            'featured_deck_id' => 'sometimes|nullable|exists:decks,id',
        ]);
        $article->update($validated);
        $article->validateRules();
        try {
            $article->validateImplies();
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 422);
        }

        return response()->json($article);
    }

    public function destroy(Article $article): JsonResponse
    {
        $article->delete();
        return response()->json(null, 204);
    }
    public function publish(Request $request, Article $article): JsonResponse
    {
        $article->publish();
        $article->save();
        return response()->json(null, 204);
    }

    public function archive(Request $request, Article $article): JsonResponse
    {
        $article->archive();
        $article->save();
        return response()->json(null, 204);
    }

    public function incrementView(Request $request, Article $article): JsonResponse
    {
        $article->incrementView();
        $article->save();
        return response()->json(null, 204);
    }

    public function readingTimeMinutes(Request $request, Article $article): JsonResponse
    {
        $result = $article->readingTimeMinutes();
        $article->save();
        return response()->json(['result' => $result]);
    }
}
