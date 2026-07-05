<?php

namespace App\Http\Controllers\Api\Tournaments;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Tournaments\Tournament;
use App\Models\Tournaments\Season;
use App\Models\Players\Player;

class TournamentController extends Controller
{

    public function index(Request $request): JsonResponse
    {
        $q = $request->query('q');
        if ($q) {
            $items = Tournament::query()
                ->where('name', 'like', '%' . $q . '%')
                ->orWhere('description', 'like', '%' . $q . '%')->get();
        } else {
            $items = Tournament::all();
        }
        return response()->json($items);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'public_id' => 'required|unique:tournaments,public_id',
            'name' => 'required|string|max:200',
            'description' => 'nullable|string|max:200',
            'status' => 'required|string|in:Draft,Registration,Ongoing,Completed,Cancelled|max:20',
            'bracket_data' => 'nullable',
            'format' => 'required|string|in:Standard,Extended,Legacy,Vintage,Commander,Draft|max:20',
            'tournament_type' => 'required|string|in:Swiss,SingleElimination,DoubleElimination,RoundRobin|max:20',
            'max_players' => 'required|integer|min:2|max:512',
            'entry_fee' => 'required',
            'prize_pool' => 'required',
            'start_time' => 'required|date',
            'end_time' => 'nullable|date',
            'is_online' => 'required|boolean',
            'location' => 'nullable|string|max:300',
            'rules_text' => 'nullable|string|max:200',
            'created_at' => 'required|date',
            'season_id' => 'required|exists:seasons,id',
            'organizer_id' => 'required|exists:players,id',
        ]);
        $item = Tournament::create($validated);
        $item->validateRules();
        try {
            $item->validateImplies();
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 422);
        }

        return response()->json($item, 201);
    }

    public function show(Tournament $tournament): JsonResponse
    {
        return response()->json($tournament);
    }

    public function update(Request $request, Tournament $tournament): JsonResponse
    {
        $validated = $request->validate([
            'public_id' => 'sometimes|nullable',
            'name' => 'sometimes|nullable|string|max:200',
            'description' => 'sometimes|nullable|string|max:200',
            'bracket_data' => 'sometimes|nullable',
            'format' => 'sometimes|nullable|string|max:20',
            'tournament_type' => 'sometimes|nullable|string|max:20',
            'max_players' => 'sometimes|nullable|integer',
            'entry_fee' => 'sometimes|nullable',
            'prize_pool' => 'sometimes|nullable',
            'start_time' => 'sometimes|nullable|date',
            'end_time' => 'sometimes|nullable|date',
            'is_online' => 'sometimes|nullable|boolean',
            'location' => 'sometimes|nullable|string|max:300',
            'rules_text' => 'sometimes|nullable|string|max:200',
            'season_id' => 'sometimes|nullable|exists:seasons,id',
            'organizer_id' => 'sometimes|nullable|exists:players,id',
        ]);
        $tournament->update($validated);
        $tournament->validateRules();
        try {
            $tournament->validateImplies();
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 422);
        }

        return response()->json($tournament);
    }

    public function start(Request $request, Tournament $tournament): JsonResponse
    {
        $tournament->start();
        $tournament->save();
        return response()->json(null, 204);
    }

    public function cancel(Request $request, Tournament $tournament): JsonResponse
    {
        $tournament->cancel();
        $tournament->save();
        return response()->json(null, 204);
    }

    public function complete(Request $request, Tournament $tournament): JsonResponse
    {
        $tournament->complete();
        $tournament->save();
        return response()->json(null, 204);
    }

    public function generateRound(Request $request, Tournament $tournament): JsonResponse
    {
        $tournament->generateRound();
        $tournament->save();
        return response()->json(null, 204);
    }

    public function calculatePrizeDistribution(Request $request, Tournament $tournament): JsonResponse
    {
        $result = $tournament->calculatePrizeDistribution();
        $tournament->save();
        return response()->json(['result' => $result]);
    }

    public function registerPlayer(Request $request, Tournament $tournament): JsonResponse
    {
        $player_id = $request->input('player_id');
        $deck_id = $request->input('deck_id');
        $tournament->registerPlayer($player_id, $deck_id);
        $tournament->save();
        return response()->json(null, 204);
    }

    public function isFull(Request $request, Tournament $tournament): JsonResponse
    {
        $result = $tournament->isFull();
        $tournament->save();
        return response()->json(['result' => $result]);
    }
    public function transitionDraftToRegistration(Tournament $tournament): JsonResponse
    {
        if (!in_array(auth()->user()?->role, ['Admin', 'Organizer'], true)) {
            return response()->json(['error' => 'Insufficient role for transition Draft -> Registration'], 403);
        }
        try {
            $tournament->assertTransition('Registration');
        } catch (\InvalidArgumentException $e) {
            return response()->json(['error' => $e->getMessage()], 409);
        }
        try {
            if ($tournament->name === null) {
                throw new \RuntimeException('name is required for Draft -> Registration');
            }
            if ($tournament->start_time === null) {
                throw new \RuntimeException('start_time is required for Draft -> Registration');
            }
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 422);
        }
        $tournament->status = 'Registration';
        $tournament->save();
        return response()->json($tournament);
    }

    public function transitionRegistrationToOngoing(Tournament $tournament): JsonResponse
    {
        if (!in_array(auth()->user()?->role, ['Admin', 'Organizer'], true)) {
            return response()->json(['error' => 'Insufficient role for transition Registration -> Ongoing'], 403);
        }
        try {
            $tournament->assertTransition('Ongoing');
        } catch (\InvalidArgumentException $e) {
            return response()->json(['error' => $e->getMessage()], 409);
        }
        $tournament->status = 'Ongoing';
        $tournament->start(); // @after
        $tournament->save();
        return response()->json($tournament);
    }

    public function transitionRegistrationToCancelled(Tournament $tournament): JsonResponse
    {
        if (!in_array(auth()->user()?->role, ['Admin', 'Organizer'], true)) {
            return response()->json(['error' => 'Insufficient role for transition Registration -> Cancelled'], 403);
        }
        try {
            $tournament->assertTransition('Cancelled');
        } catch (\InvalidArgumentException $e) {
            return response()->json(['error' => $e->getMessage()], 409);
        }
        $tournament->status = 'Cancelled';
        $tournament->cancel(); // @after
        $tournament->save();
        return response()->json($tournament);
    }

    public function transitionOngoingToCompleted(Tournament $tournament): JsonResponse
    {
        if (!in_array(auth()->user()?->role, ['Admin', 'Organizer'], true)) {
            return response()->json(['error' => 'Insufficient role for transition Ongoing -> Completed'], 403);
        }
        try {
            $tournament->assertTransition('Completed');
        } catch (\InvalidArgumentException $e) {
            return response()->json(['error' => $e->getMessage()], 409);
        }
        $tournament->status = 'Completed';
        $tournament->complete(); // @after
        $tournament->calculatePrizeDistribution(); // @after
        $tournament->save();
        return response()->json($tournament);
    }

    public function transitionOngoingToCancelled(Tournament $tournament): JsonResponse
    {
        if (!in_array(auth()->user()?->role, ['Admin'], true)) {
            return response()->json(['error' => 'Insufficient role for transition Ongoing -> Cancelled'], 403);
        }
        try {
            $tournament->assertTransition('Cancelled');
        } catch (\InvalidArgumentException $e) {
            return response()->json(['error' => $e->getMessage()], 409);
        }
        $tournament->status = 'Cancelled';
        $tournament->cancel(); // @after
        $tournament->save();
        return response()->json($tournament);
    }

    public function transitionCompletedToDraft(Tournament $tournament): JsonResponse
    {
        return response()->json(['error' => 'Transition Completed -> Draft is not allowed'], 409);
    }

    public function transitionCancelledToDraft(Tournament $tournament): JsonResponse
    {
        return response()->json(['error' => 'Transition Cancelled -> Draft is not allowed'], 409);
    }
}
