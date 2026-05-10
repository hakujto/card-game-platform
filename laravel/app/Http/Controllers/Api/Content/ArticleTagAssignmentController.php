<?php

namespace App\Http\Controllers\Api\Content;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Content\ArticleTagAssignment;
use App\Models\Content\Article;
use App\Models\Content\ArticleTag;

class ArticleTagAssignmentController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json(ArticleTagAssignment::all());
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'article_id' => 'required|exists:articles,id',
            'tag_id' => 'required|exists:article_tags,id',
        ]);
        $item = ArticleTagAssignment::create($validated);
        return response()->json($item, 201);
    }

    public function show(ArticleTagAssignment $articleTagAssignment): JsonResponse
    {
        return response()->json($articleTagAssignment);
    }

    public function update(Request $request, ArticleTagAssignment $articleTagAssignment): JsonResponse
    {
        $validated = $request->validate([
            'article_id' => 'sometimes|nullable|exists:articles,id',
            'tag_id' => 'sometimes|nullable|exists:article_tags,id',
        ]);
        $articleTagAssignment->update($validated);
        return response()->json($articleTagAssignment);
    }

    public function destroy(ArticleTagAssignment $articleTagAssignment): JsonResponse
    {
        $articleTagAssignment->delete();
        return response()->json(null, 204);
    }
}
