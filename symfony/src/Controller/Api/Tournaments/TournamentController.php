<?php

namespace App\Controller\Api\Tournaments;

use App\Entity\Tournaments\Tournament;
use App\Repository\Tournaments\TournamentRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Tournaments\Season;
use App\Repository\Tournaments\SeasonRepository;
use App\Entity\Players\Player;
use App\Repository\Players\PlayerRepository;
use App\Entity\Tournaments\TournamentRegistration;
use App\Repository\Tournaments\TournamentRegistrationRepository;
use App\Entity\Tournaments\TournamentRound;
use App\Repository\Tournaments\TournamentRoundRepository;
use App\Entity\Tournaments\TournamentPrize;
use App\Repository\Tournaments\TournamentPrizeRepository;

#[Route('/api/tournaments', name: 'tournament_')]
class TournamentController extends AbstractController
{
    public function __construct(
        private TournamentRepository $repository,
        private ValidatorInterface $validator,
        private SeasonRepository $seasonRepository,
        private PlayerRepository $playerRepository,
        private TournamentRegistrationRepository $tournamentRegistrationRepository,
        private TournamentRoundRepository $tournamentRoundRepository,
        private TournamentPrizeRepository $tournamentPrizeRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['tournament:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $tournament = new Tournament();
        if (isset($data['name'])) $tournament->setName($data['name']);
        if (isset($data['description'])) $tournament->setDescription($data['description']);
        if (isset($data['format'])) $tournament->setFormat($data['format']);
        if (isset($data['tournamentType'])) $tournament->setTournamentType($data['tournamentType']);
        if (isset($data['status'])) $tournament->setStatus($data['status']);
        if (isset($data['maxPlayers'])) $tournament->setMaxPlayers($data['maxPlayers']);
        if (isset($data['entryFee'])) $tournament->setEntryFee($data['entryFee']);
        if (isset($data['prizePool'])) $tournament->setPrizePool($data['prizePool']);
        if (isset($data['startTime'])) $tournament->setStartTime(new \DateTime($data['startTime']));
        if (isset($data['endTime'])) $tournament->setEndTime(new \DateTime($data['endTime']));
        if (isset($data['isOnline'])) $tournament->setIsOnline($data['isOnline']);
        if (isset($data['location'])) $tournament->setLocation($data['location']);
        if (isset($data['rulesText'])) $tournament->setRulesText($data['rulesText']);
        if (isset($data['createdAt'])) $tournament->setCreatedAt(new \DateTime($data['createdAt']));
        if (!isset($data['season'])) return $this->json(['error' => 'season is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_season = $this->seasonRepository->find($data['season']);
        if (!$rel_season) return $this->json(['error' => 'Season not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $tournament->setSeason($rel_season);
        if (!isset($data['organizer'])) return $this->json(['error' => 'organizer is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_organizer = $this->playerRepository->find($data['organizer']);
        if (!$rel_organizer) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $tournament->setOrganizer($rel_organizer);
        if (array_key_exists('registrations', $data)) {
            $tournament->setRegistrations($data['registrations'] !== null ? $this->tournamentRegistrationRepository->find($data['registrations']) : null);
        }
        if (array_key_exists('rounds', $data)) {
            $tournament->setRounds($data['rounds'] !== null ? $this->tournamentRoundRepository->find($data['rounds']) : null);
        }
        if (array_key_exists('prizes', $data)) {
            $tournament->setPrizes($data['prizes'] !== null ? $this->tournamentPrizeRepository->find($data['prizes']) : null);
        }

        $errors = $this->validator->validate($tournament);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($tournament, flush: true);
        return $this->json($tournament, Response::HTTP_CREATED, context: ['groups' => ['tournament:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(Tournament $tournament): JsonResponse
    {
        return $this->json($tournament, context: ['groups' => ['tournament:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, Tournament $tournament): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['name'])) $tournament->setName($data['name']);
        if (isset($data['description'])) $tournament->setDescription($data['description']);
        if (isset($data['format'])) $tournament->setFormat($data['format']);
        if (isset($data['tournamentType'])) $tournament->setTournamentType($data['tournamentType']);
        if (isset($data['status'])) $tournament->setStatus($data['status']);
        if (isset($data['maxPlayers'])) $tournament->setMaxPlayers($data['maxPlayers']);
        if (isset($data['entryFee'])) $tournament->setEntryFee($data['entryFee']);
        if (isset($data['prizePool'])) $tournament->setPrizePool($data['prizePool']);
        if (isset($data['startTime'])) $tournament->setStartTime(new \DateTime($data['startTime']));
        if (isset($data['endTime'])) $tournament->setEndTime(new \DateTime($data['endTime']));
        if (isset($data['isOnline'])) $tournament->setIsOnline($data['isOnline']);
        if (isset($data['location'])) $tournament->setLocation($data['location']);
        if (isset($data['rulesText'])) $tournament->setRulesText($data['rulesText']);
        if (isset($data['createdAt'])) $tournament->setCreatedAt(new \DateTime($data['createdAt']));
        if (isset($data['season'])) {
            $rel_season = $this->seasonRepository->find($data['season']);
            if (!$rel_season) return $this->json(['error' => 'Season not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $tournament->setSeason($rel_season);
        }
        if (isset($data['organizer'])) {
            $rel_organizer = $this->playerRepository->find($data['organizer']);
            if (!$rel_organizer) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $tournament->setOrganizer($rel_organizer);
        }
        if (array_key_exists('registrations', $data)) {
            $tournament->setRegistrations($data['registrations'] !== null ? $this->tournamentRegistrationRepository->find($data['registrations']) : null);
        }
        if (array_key_exists('rounds', $data)) {
            $tournament->setRounds($data['rounds'] !== null ? $this->tournamentRoundRepository->find($data['rounds']) : null);
        }
        if (array_key_exists('prizes', $data)) {
            $tournament->setPrizes($data['prizes'] !== null ? $this->tournamentPrizeRepository->find($data['prizes']) : null);
        }

        $errors = $this->validator->validate($tournament);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($tournament, flush: true);
        return $this->json($tournament, context: ['groups' => ['tournament:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(Tournament $tournament): JsonResponse
    {
        $this->repository->remove($tournament, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
