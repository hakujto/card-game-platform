<?php

namespace App\Http\Controllers\Api\Marketplace;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Marketplace\Product;
use App\Models\Cards\Card;
use App\Models\Cards\CardSet;

class ProductController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json(Product::all());
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:200',
            'product_type' => 'required|string|in:SingleCard,BoosterPack,Bundle,PreconstructedDeck,Accessory|max:20',
            'price' => 'required|max:200',
            'stock' => 'required|integer|max:200',
            'active' => 'required|boolean|max:200',
            'discount_percent' => 'required|integer|max:200',
            'description' => 'nullable|string|max:200',
            'image_url' => 'nullable|string|url|max:200',
            'featured' => 'required|boolean|max:200',
            'card_id' => 'nullable|exists:cards,id',
            'card_set_id' => 'nullable|exists:card_sets,id',
        ]);
        $item = Product::create($validated);
        return response()->json($item, 201);
    }

    public function show(Product $product): JsonResponse
    {
        return response()->json($product);
    }

    public function update(Request $request, Product $product): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'sometimes|nullable|string|max:200',
            'product_type' => 'sometimes|nullable|string|max:20',
            'price' => 'sometimes|nullable|max:200',
            'stock' => 'sometimes|nullable|integer|max:200',
            'active' => 'sometimes|nullable|boolean|max:200',
            'discount_percent' => 'sometimes|nullable|integer|max:200',
            'description' => 'sometimes|nullable|string|max:200',
            'image_url' => 'sometimes|nullable|string|url|max:200',
            'featured' => 'sometimes|nullable|boolean|max:200',
            'card_id' => 'sometimes|nullable|exists:cards,id',
            'card_set_id' => 'sometimes|nullable|exists:card_sets,id',
        ]);
        $product->update($validated);
        return response()->json($product);
    }

    public function destroy(Product $product): JsonResponse
    {
        $product->delete();
        return response()->json(null, 204);
    }
}
