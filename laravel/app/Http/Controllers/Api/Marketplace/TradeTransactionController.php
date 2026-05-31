<?php

namespace App\Http\Controllers\Api\Marketplace;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Marketplace\TradeTransaction;
use App\Models\Marketplace\TradeListing;
use App\Models\Players\Player;

class TradeTransactionController extends Controller
{

    public function index(): JsonResponse
    {
        return response()->json(TradeTransaction::all());
    }

    public function show(TradeTransaction $tradeTransaction): JsonResponse
    {
        return response()->json($tradeTransaction);
    }

    public function complete(Request $request, TradeTransaction $tradeTransaction): JsonResponse
    {
        $tradeTransaction->complete();
        $tradeTransaction->save();
        return response()->json(null, 204);
    }

    public function refund(Request $request, TradeTransaction $tradeTransaction): JsonResponse
    {
        $tradeTransaction->refund();
        $tradeTransaction->save();
        return response()->json(null, 204);
    }

    public function openDispute(Request $request, TradeTransaction $tradeTransaction): JsonResponse
    {
        $reason = $request->input('reason');
        $tradeTransaction->openDispute($reason);
        $tradeTransaction->save();
        return response()->json(null, 204);
    }

    public function sellerNet(Request $request, TradeTransaction $tradeTransaction): JsonResponse
    {
        $result = $tradeTransaction->sellerNet();
        $tradeTransaction->save();
        return response()->json(['result' => $result]);
    }
}
