<?php

namespace App\Http\Controllers\Api\Marketplace;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Marketplace\CardPriceHistory;
use App\Models\Cards\Card;

class CardPriceHistoryController extends Controller
{

    public function index(): JsonResponse
    {
        return response()->json(CardPriceHistory::all());
    }

    public function show(CardPriceHistory $cardPriceHistory): JsonResponse
    {
        return response()->json($cardPriceHistory);
    }

    public function priceChangePercent(Request $request, CardPriceHistory $cardPriceHistory): JsonResponse
    {
        $result = $cardPriceHistory->priceChangePercent();
        $cardPriceHistory->save();
        return response()->json(['result' => $result]);
    }

    public function isPriceSpike(Request $request, CardPriceHistory $cardPriceHistory): JsonResponse
    {
        $result = $cardPriceHistory->isPriceSpike();
        $cardPriceHistory->save();
        return response()->json(['result' => $result]);
    }
}
