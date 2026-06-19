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

    public function index(Request $request): JsonResponse
    {
        $q = $request->query('q');
        if ($q) {
            $items = Article::query()
                ->where('title', 'like', '%' . $q . '%')
                ->orWhere('excerpt', 'like', '%' . $q . '%')->get();
        } else {
            $items = Article::all();
        }
        return response()->json($items);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'title' => 'required|string|max:300',
            'slug' => 'required|string|max:300|unique:articles,slug',
            'body' => 'required|string|max:200',
            'excerpt' => 'nullable|string|max:200',
            'cover_image_url' => 'nullable|string|url|max:200',
            'status' => 'required|string|in:Draft,Published,Archived|max:20',
            'article_type' => 'required|string|in:Guide,Tierlist,Matchup,News,Spotlight,Decklist|max:20',
            'language' => 'required|string|in:EN,DE,FR,IT,ES,JP,PT|max:20',
            'view_count' => 'required|integer',
            'likes_count' => 'required|integer',
            'is_featured' => 'required|boolean',
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
            'language' => 'sometimes|nullable|string|max:20',
            'view_count' => 'sometimes|nullable|integer',
            'likes_count' => 'sometimes|nullable|integer',
            'is_featured' => 'sometimes|nullable|boolean',
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

    public function like(Request $request, Article $article): JsonResponse
    {
        $article->like();
        $article->save();
        return response()->json(null, 204);
    }

    public function unlike(Request $request, Article $article): JsonResponse
    {
        $article->unlike();
        $article->save();
        return response()->json(null, 204);
    }

    public function readingTimeMinutes(Request $request, Article $article): JsonResponse
    {
        $result = $article->readingTimeMinutes();
        $article->save();
        return response()->json(['result' => $result]);
    }
    public function transitionDraftToPublished(Article $article): JsonResponse
    {
        if (!in_array(auth()->user()?->role, ['Editor', 'Admin'], true)) {
            return response()->json(['error' => 'Insufficient role for transition Draft -> Published'], 403);
        }
        try {
            $article->assertTransition('Published');
        } catch (\InvalidArgumentException $e) {
            return response()->json(['error' => $e->getMessage()], 409);
        }
        try {
            if ($article->title === null) {
                throw new \RuntimeException('title is required for Draft -> Published');
            }
            if ($article->body === null) {
                throw new \RuntimeException('body is required for Draft -> Published');
            }
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 422);
        }
        $article->status = 'Published';
        $article->publish(); // @after
        $article->save();
        return response()->json($article);
    }

    public function transitionPublishedToArchived(Article $article): JsonResponse
    {
        if (!in_array(auth()->user()?->role, ['Editor', 'Admin'], true)) {
            return response()->json(['error' => 'Insufficient role for transition Published -> Archived'], 403);
        }
        try {
            $article->assertTransition('Archived');
        } catch (\InvalidArgumentException $e) {
            return response()->json(['error' => $e->getMessage()], 409);
        }
        $article->status = 'Archived';
        $article->archive(); // @after
        $article->save();
        return response()->json($article);
    }

    public function transitionArchivedToDraft(Article $article): JsonResponse
    {
        if (!in_array(auth()->user()?->role, ['Admin'], true)) {
            return response()->json(['error' => 'Insufficient role for transition Archived -> Draft'], 403);
        }
        try {
            $article->assertTransition('Draft');
        } catch (\InvalidArgumentException $e) {
            return response()->json(['error' => $e->getMessage()], 409);
        }
        $article->status = 'Draft';
        $article->save();
        return response()->json($article);
    }

    public function transitionPublishedToDraft(Article $article): JsonResponse
    {
        return response()->json(['error' => 'Transition Published -> Draft is not allowed'], 409);
    }
}
