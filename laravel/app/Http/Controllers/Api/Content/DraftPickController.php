<?php

namespace App\Http\Controllers\Api\Content;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Content\DraftPick;
use App\Models\Content\DraftParticipant;
use App\Models\Cards\Card;

class DraftPickController extends Controller
{

    public function index(): JsonResponse
    {
        return response()->json(DraftPick::all());
    }

    public function show(DraftPick $draftPick): JsonResponse
    {
        return response()->json($draftPick);
    }

    public function isFirstPick(Request $request, DraftPick $draftPick): JsonResponse
    {
        $result = $draftPick->isFirstPick();
        $draftPick->save();
        return response()->json(['result' => $result]);
    }
}
