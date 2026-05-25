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

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(AwardedPrize $awardedPrize): JsonResponse
    {
        return $this->json($awardedPrize, context: ['groups' => ['awardedPrize:read']]);
    }

    #[Route('/{id}/claim', name: 'claim', methods: ['POST'])]
    public function claim(AwardedPrize $awardedPrize): JsonResponse
    {
        $awardedPrize->claim();
        $this->repository->save($awardedPrize, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
