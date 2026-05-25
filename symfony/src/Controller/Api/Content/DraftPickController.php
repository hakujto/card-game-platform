<?php

namespace App\Controller\Api\Content;

use App\Entity\Content\DraftPick;
use App\Repository\Content\DraftPickRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Content\DraftParticipant;
use App\Repository\Content\DraftParticipantRepository;
use App\Entity\Cards\Card;
use App\Repository\Cards\CardRepository;

#[Route('/api/draft_picks', name: 'draftPick_')]
class DraftPickController extends AbstractController
{
    public function __construct(
        private DraftPickRepository $repository,
        private ValidatorInterface $validator,
        private DraftParticipantRepository $draftParticipantRepository,
        private CardRepository $cardRepository,
    ) {}


    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['draftPick:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(DraftPick $draftPick): JsonResponse
    {
        return $this->json($draftPick, context: ['groups' => ['draftPick:read']]);
    }

    #[Route('/{id}/first-pick', name: 'isFirstPick', methods: ['GET'])]
    public function isFirstPick(DraftPick $draftPick): JsonResponse
    {
        $result = $draftPick->isFirstPick();
        $this->repository->save($draftPick, flush: true);
        return $this->json($result);
    }
}
