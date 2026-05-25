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
use App\Service\Tournaments\TournamentService;
use App\Entity\Tournaments\Season;
use App\Repository\Tournaments\SeasonRepository;
use App\Entity\Players\Player;
use App\Repository\Players\PlayerRepository;

#[Route('/api/tournaments', name: 'tournament_')]
class TournamentController extends AbstractController
{
    public function __construct(
        private TournamentRepository $repository,
        private ValidatorInterface $validator,
        private TournamentService $service,
        private SeasonRepository $seasonRepository,
        private PlayerRepository $playerRepository,
    ) {}


    #[Route('', name: 'list', methods: ['GET'])]
    public function list(Request $request): JsonResponse
    {
        $q = $request->query->get('q');
        if ($q) {
            $qb = $this->repository->createQueryBuilder('e');
            $items = $qb->where($qb->expr()->orX($qb->expr()->like('e.name', ':q'), $qb->expr()->like('e.description', ':q')))
                ->setParameter('q', '%' . $q . '%')
                ->getQuery()->getResult();
        } else {
            $items = $this->repository->findAll();
        }
        return $this->json($items, context: ['groups' => ['tournament:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $tournament = new Tournament();
        if (isset($data['name'])) $tournament->setName($data['name']);
        if (isset($data['description'])) $tournament->setDescription($data['description']);
        if (isset($data['status'])) $tournament->setStatus($data['status']);
        if (isset($data['format'])) $tournament->setFormat($data['format']);
        if (isset($data['tournamentType'])) $tournament->setTournamentType($data['tournamentType']);
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

        $errors = $this->validator->validate($tournament);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        try {
            $tournament->validateImplies();
        } catch (\DomainException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_UNPROCESSABLE_ENTITY);
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
        if (isset($data['status'])) $tournament->setStatus($data['status']);
        if (isset($data['format'])) $tournament->setFormat($data['format']);
        if (isset($data['tournamentType'])) $tournament->setTournamentType($data['tournamentType']);
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

        $errors = $this->validator->validate($tournament);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        try {
            $tournament->validateImplies();
        } catch (\DomainException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($tournament, flush: true);
        return $this->json($tournament, context: ['groups' => ['tournament:read']]);
    }

    #[Route('/{id}/start', name: 'start', methods: ['POST'])]
    public function start(Tournament $tournament): JsonResponse
    {
        $tournament->start();
        $this->repository->save($tournament, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/cancel', name: 'cancel', methods: ['POST'])]
    public function cancel(Tournament $tournament): JsonResponse
    {
        $tournament->cancel();
        $this->repository->save($tournament, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/complete', name: 'complete', methods: ['POST'])]
    public function complete(Tournament $tournament): JsonResponse
    {
        $tournament->complete();
        $this->repository->save($tournament, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/rounds', name: 'generateRound', methods: ['POST'])]
    public function generateRound(Tournament $tournament): JsonResponse
    {
        $tournament->generateRound();
        $this->repository->save($tournament, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/prizes', name: 'calculatePrizeDistribution', methods: ['GET'])]
    public function calculatePrizeDistribution(Tournament $tournament): JsonResponse
    {
        $result = $tournament->calculatePrizeDistribution();
        $this->repository->save($tournament, flush: true);
        return $this->json($result);
    }

    #[Route('/{id}/register', name: 'registerPlayer', methods: ['POST'])]
    public function registerPlayer(Tournament $tournament, Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $tournament->registerPlayer($data['playerId'] ?? null, $data['deckId'] ?? null);
        $this->repository->save($tournament, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/full', name: 'isFull', methods: ['GET'])]
    public function isFull(Tournament $tournament): JsonResponse
    {
        $result = $tournament->isFull();
        $this->repository->save($tournament, flush: true);
        return $this->json($result);
    }
    #[Route('/{id}/transitions/draft-to-registration', name: 'tournament_transitionDraftToRegistration', methods: ['PATCH'])]
    public function transitionDraftToRegistration(Tournament $tournament): JsonResponse
    {
        try {
            $result = $this->service->transitionDraftToRegistration($tournament->getId());
            return $this->json($result);
        } catch (\Symfony\Component\HttpKernel\Exception\ConflictHttpException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_CONFLICT);
        } catch (\Symfony\Component\HttpKernel\Exception\UnprocessableEntityHttpException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_UNPROCESSABLE_ENTITY);
        }
    }

    #[Route('/{id}/transitions/registration-to-ongoing', name: 'tournament_transitionRegistrationToOngoing', methods: ['PATCH'])]
    public function transitionRegistrationToOngoing(Tournament $tournament): JsonResponse
    {
        try {
            $result = $this->service->transitionRegistrationToOngoing($tournament->getId());
            return $this->json($result);
        } catch (\Symfony\Component\HttpKernel\Exception\ConflictHttpException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_CONFLICT);
        } catch (\Symfony\Component\HttpKernel\Exception\UnprocessableEntityHttpException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_UNPROCESSABLE_ENTITY);
        }
    }

    #[Route('/{id}/transitions/registration-to-cancelled', name: 'tournament_transitionRegistrationToCancelled', methods: ['PATCH'])]
    public function transitionRegistrationToCancelled(Tournament $tournament): JsonResponse
    {
        try {
            $result = $this->service->transitionRegistrationToCancelled($tournament->getId());
            return $this->json($result);
        } catch (\Symfony\Component\HttpKernel\Exception\ConflictHttpException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_CONFLICT);
        } catch (\Symfony\Component\HttpKernel\Exception\UnprocessableEntityHttpException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_UNPROCESSABLE_ENTITY);
        }
    }

    #[Route('/{id}/transitions/ongoing-to-completed', name: 'tournament_transitionOngoingToCompleted', methods: ['PATCH'])]
    public function transitionOngoingToCompleted(Tournament $tournament): JsonResponse
    {
        try {
            $result = $this->service->transitionOngoingToCompleted($tournament->getId());
            return $this->json($result);
        } catch (\Symfony\Component\HttpKernel\Exception\ConflictHttpException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_CONFLICT);
        } catch (\Symfony\Component\HttpKernel\Exception\UnprocessableEntityHttpException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_UNPROCESSABLE_ENTITY);
        }
    }

    #[Route('/{id}/transitions/ongoing-to-cancelled', name: 'tournament_transitionOngoingToCancelled', methods: ['PATCH'])]
    public function transitionOngoingToCancelled(Tournament $tournament): JsonResponse
    {
        try {
            $result = $this->service->transitionOngoingToCancelled($tournament->getId());
            return $this->json($result);
        } catch (\Symfony\Component\HttpKernel\Exception\ConflictHttpException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_CONFLICT);
        } catch (\Symfony\Component\HttpKernel\Exception\UnprocessableEntityHttpException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_UNPROCESSABLE_ENTITY);
        }
    }

    #[Route('/{id}/transitions/completed-to-draft', name: 'tournament_transitionCompletedToDraft', methods: ['PATCH'])]
    public function transitionCompletedToDraft(Tournament $tournament): JsonResponse
    {
        return $this->json(['error' => 'Transition Completed -> Draft is not allowed'], Response::HTTP_CONFLICT);
    }

    #[Route('/{id}/transitions/cancelled-to-draft', name: 'tournament_transitionCancelledToDraft', methods: ['PATCH'])]
    public function transitionCancelledToDraft(Tournament $tournament): JsonResponse
    {
        return $this->json(['error' => 'Transition Cancelled -> Draft is not allowed'], Response::HTTP_CONFLICT);
    }
}
