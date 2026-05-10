<?php

namespace App\Http\Controllers\Api\Content;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Content\ArticleTag;

class ArticleTagController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json(ArticleTag::all());
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:100',
            'slug' => 'required|string|max:100',
        ]);
        $item = ArticleTag::create($validated);
        return response()->json($item, 201);
    }

    public function show(ArticleTag $articleTag): JsonResponse
    {
        return response()->json($articleTag);
    }

    public function update(Request $request, ArticleTag $articleTag): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'sometimes|nullable|string|max:100',
            'slug' => 'sometimes|nullable|string|max:100',
        ]);
        $articleTag->update($validated);
        return response()->json($articleTag);
    }

    public function destroy(ArticleTag $articleTag): JsonResponse
    {
        $articleTag->delete();
        return response()->json(null, 204);
    }
}
