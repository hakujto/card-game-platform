<?php

namespace App\Http\Controllers\Api\Content;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Content\ArticleComment;
use App\Models\Content\Article;
use App\Models\Players\Player;

class ArticleCommentController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json(ArticleComment::all());
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'body' => 'required|string|max:200',
            'is_hidden' => 'required|boolean|max:200',
            'created_at' => 'required|date|max:200',
            'article_id' => 'nullable|exists:articles,id',
            'author_id' => 'required|exists:players,id',
            'parent_comment_id' => 'nullable|exists:article_comments,id',
        ]);
        $item = ArticleComment::create($validated);
        return response()->json($item, 201);
    }

    public function show(ArticleComment $articleComment): JsonResponse
    {
        return response()->json($articleComment);
    }

    public function update(Request $request, ArticleComment $articleComment): JsonResponse
    {
        $validated = $request->validate([
            'body' => 'sometimes|nullable|string|max:200',
            'is_hidden' => 'sometimes|nullable|boolean|max:200',
            'created_at' => 'sometimes|nullable|date|max:200',
            'article_id' => 'sometimes|nullable|exists:articles,id',
            'author_id' => 'sometimes|nullable|exists:players,id',
            'parent_comment_id' => 'sometimes|nullable|exists:article_comments,id',
        ]);
        $articleComment->update($validated);
        return response()->json($articleComment);
    }

    public function destroy(ArticleComment $articleComment): JsonResponse
    {
        $articleComment->delete();
        return response()->json(null, 204);
    }
}
