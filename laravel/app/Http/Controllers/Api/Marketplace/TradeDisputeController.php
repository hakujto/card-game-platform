<?php

namespace App\Http\Controllers\Api\Marketplace;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Marketplace\TradeDispute;
use App\Models\Marketplace\TradeTransaction;
use App\Models\Players\Player;

class TradeDisputeController extends Controller
{

    public function index(): JsonResponse
    {
        return response()->json(TradeDispute::all());
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'status' => 'required|string|in:Open,UnderReview,Resolved,Escalated|max:20',
            'reason' => 'required|string|in:ItemNotReceived,ItemNotAsDescribed,FraudSuspected,Other|max:20',
            'description' => 'required|string|max:200',
            'resolution' => 'nullable|string|max:200',
            'opened_at' => 'required|date',
            'resolved_at' => 'nullable|date',
            'transaction_id' => 'required|exists:trade_transactions,id',
            'opened_by_id' => 'required|exists:players,id',
            'resolved_by_id' => 'nullable|exists:players,id',
        ]);
        $item = TradeDispute::create($validated);
        try {
            $item->validateImplies();
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 422);
        }

        return response()->json($item, 201);
    }

    public function show(TradeDispute $tradeDispute): JsonResponse
    {
        return response()->json($tradeDispute);
    }

    public function escalate(Request $request, TradeDispute $tradeDispute): JsonResponse
    {
        $tradeDispute->escalate();
        $tradeDispute->save();
        return response()->json(null, 204);
    }

    public function resolve(Request $request, TradeDispute $tradeDispute): JsonResponse
    {
        $resolution_text = $request->input('resolution_text');
        $tradeDispute->resolve($resolution_text);
        $tradeDispute->save();
        return response()->json(null, 204);
    }

    public function closeResolved(Request $request, TradeDispute $tradeDispute): JsonResponse
    {
        $tradeDispute->closeResolved();
        $tradeDispute->save();
        return response()->json(null, 204);
    }

    public function review(Request $request, TradeDispute $tradeDispute): JsonResponse
    {
        $tradeDispute->review();
        $tradeDispute->save();
        return response()->json(null, 204);
    }
    public function transitionOpenToUnderReview(TradeDispute $tradeDispute): JsonResponse
    {
        if (!in_array(auth()->user()?->role, ['Admin', 'Moderator'], true)) {
            return response()->json(['error' => 'Insufficient role for transition Open -> UnderReview'], 403);
        }
        try {
            $tradeDispute->assertTransition('UnderReview');
        } catch (\InvalidArgumentException $e) {
            return response()->json(['error' => $e->getMessage()], 409);
        }
        $tradeDispute->status = 'UnderReview';
        $tradeDispute->review(); // @after
        $tradeDispute->save();
        return response()->json($tradeDispute);
    }

    public function transitionUnderReviewToResolved(TradeDispute $tradeDispute): JsonResponse
    {
        if (!in_array(auth()->user()?->role, ['Admin', 'Moderator'], true)) {
            return response()->json(['error' => 'Insufficient role for transition UnderReview -> Resolved'], 403);
        }
        try {
            $tradeDispute->assertTransition('Resolved');
        } catch (\InvalidArgumentException $e) {
            return response()->json(['error' => $e->getMessage()], 409);
        }
        try {
            if ($tradeDispute->resolution === null) {
                throw new \RuntimeException('resolution is required for UnderReview -> Resolved');
            }
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 422);
        }
        $tradeDispute->status = 'Resolved';
        $tradeDispute->closeResolved(); // @after
        $tradeDispute->save();
        return response()->json($tradeDispute);
    }

    public function transitionUnderReviewToEscalated(TradeDispute $tradeDispute): JsonResponse
    {
        if (!in_array(auth()->user()?->role, ['Admin'], true)) {
            return response()->json(['error' => 'Insufficient role for transition UnderReview -> Escalated'], 403);
        }
        try {
            $tradeDispute->assertTransition('Escalated');
        } catch (\InvalidArgumentException $e) {
            return response()->json(['error' => $e->getMessage()], 409);
        }
        $tradeDispute->status = 'Escalated';
        $tradeDispute->escalate(); // @after
        $tradeDispute->save();
        return response()->json($tradeDispute);
    }

    public function transitionEscalatedToResolved(TradeDispute $tradeDispute): JsonResponse
    {
        if (!in_array(auth()->user()?->role, ['Admin'], true)) {
            return response()->json(['error' => 'Insufficient role for transition Escalated -> Resolved'], 403);
        }
        try {
            $tradeDispute->assertTransition('Resolved');
        } catch (\InvalidArgumentException $e) {
            return response()->json(['error' => $e->getMessage()], 409);
        }
        try {
            if ($tradeDispute->resolution === null) {
                throw new \RuntimeException('resolution is required for Escalated -> Resolved');
            }
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 422);
        }
        $tradeDispute->status = 'Resolved';
        $tradeDispute->closeResolved(); // @after
        $tradeDispute->save();
        return response()->json($tradeDispute);
    }

    public function transitionResolvedToOpen(TradeDispute $tradeDispute): JsonResponse
    {
        return response()->json(['error' => 'Transition Resolved -> Open is not allowed'], 409);
    }
}
