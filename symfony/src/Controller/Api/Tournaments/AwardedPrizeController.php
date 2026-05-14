<?php

namespace App\Controller\Api\Tournaments;

use App\Entity\Tournaments\AwardedPrize;
use App\Repository\Tournaments\AwardedPrizeRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Tournaments\TournamentPrize;
use App\Repository\Tournaments\TournamentPrizeRepository;
use App\Entity\Players\Player;
use App\Repository\Players\PlayerRepository;

#[Route('/api/awarded_prizes', name: 'awardedPrize_')]
class AwardedPrizeController extends AbstractController
{
    public function __construct(
        private AwardedPrizeRepository $repository,
        private ValidatorInterface $validator,
        private TournamentPrizeRepository $tournamentPrizeRepository,
        private PlayerRepository $playerRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['awardedPrize:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $awardedPrize = new AwardedPrize();
        if (isset($data['finalPlacement'])) $awardedPrize->setFinalPlacement($data['finalPlacement']);
        if (isset($data['awardedAt'])) $awardedPrize->setAwardedAt(new \DateTime($data['awardedAt']));
        if (isset($data['claimed'])) $awardedPrize->setClaimed($data['claimed']);
        if (isset($data['claimedAt'])) $awardedPrize->setClaimedAt(new \DateTime($data['claimedAt']));
        if (!isset($data['prize'])) return $this->json(['error' => 'prize is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_prize = $this->tournamentPrizeRepository->find($data['prize']);
        if (!$rel_prize) return $this->json(['error' => 'TournamentPrize not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $awardedPrize->setPrize($rel_prize);
        if (!isset($data['player'])) return $this->json(['error' => 'player is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_player = $this->playerRepository->find($data['player']);
        if (!$rel_player) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $awardedPrize->setPlayer($rel_player);

        $errors = $this->validator->validate($awardedPrize);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        try {
            $awardedPrize->validateImplies();
        } catch (\DomainException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($awardedPrize, flush: true);
        return $this->json($awardedPrize, Response::HTTP_CREATED, context: ['groups' => ['awardedPrize:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(AwardedPrize $awardedPrize): JsonResponse
    {
        return $this->json($awardedPrize, context: ['groups' => ['awardedPrize:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, AwardedPrize $awardedPrize): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['finalPlacement'])) $awardedPrize->setFinalPlacement($data['finalPlacement']);
        if (isset($data['awardedAt'])) $awardedPrize->setAwardedAt(new \DateTime($data['awardedAt']));
        if (isset($data['claimed'])) $awardedPrize->setClaimed($data['claimed']);
        if (isset($data['claimedAt'])) $awardedPrize->setClaimedAt(new \DateTime($data['claimedAt']));
        if (isset($data['prize'])) {
            $rel_prize = $this->tournamentPrizeRepository->find($data['prize']);
            if (!$rel_prize) return $this->json(['error' => 'TournamentPrize not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $awardedPrize->setPrize($rel_prize);
        }
        if (isset($data['player'])) {
            $rel_player = $this->playerRepository->find($data['player']);
            if (!$rel_player) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $awardedPrize->setPlayer($rel_player);
        }

        $errors = $this->validator->validate($awardedPrize);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        try {
            $awardedPrize->validateImplies();
        } catch (\DomainException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($awardedPrize, flush: true);
        return $this->json($awardedPrize, context: ['groups' => ['awardedPrize:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(AwardedPrize $awardedPrize): JsonResponse
    {
        $this->repository->remove($awardedPrize, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

}
