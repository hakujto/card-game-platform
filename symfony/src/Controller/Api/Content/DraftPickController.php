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

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $draftPick = new DraftPick();
        if (isset($data['pickNumber'])) $draftPick->setPickNumber($data['pickNumber']);
        if (isset($data['packNumber'])) $draftPick->setPackNumber($data['packNumber']);
        if (isset($data['pickedAt'])) $draftPick->setPickedAt(new \DateTime($data['pickedAt']));
        if (!isset($data['participant'])) return $this->json(['error' => 'participant is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_participant = $this->draftParticipantRepository->find($data['participant']);
        if (!$rel_participant) return $this->json(['error' => 'DraftParticipant not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $draftPick->setParticipant($rel_participant);
        if (!isset($data['card'])) return $this->json(['error' => 'card is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_card = $this->cardRepository->find($data['card']);
        if (!$rel_card) return $this->json(['error' => 'Card not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $draftPick->setCard($rel_card);

        $errors = $this->validator->validate($draftPick);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($draftPick, flush: true);
        return $this->json($draftPick, Response::HTTP_CREATED, context: ['groups' => ['draftPick:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(DraftPick $draftPick): JsonResponse
    {
        return $this->json($draftPick, context: ['groups' => ['draftPick:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, DraftPick $draftPick): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['pickNumber'])) $draftPick->setPickNumber($data['pickNumber']);
        if (isset($data['packNumber'])) $draftPick->setPackNumber($data['packNumber']);
        if (isset($data['pickedAt'])) $draftPick->setPickedAt(new \DateTime($data['pickedAt']));
        if (isset($data['participant'])) {
            $rel_participant = $this->draftParticipantRepository->find($data['participant']);
            if (!$rel_participant) return $this->json(['error' => 'DraftParticipant not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $draftPick->setParticipant($rel_participant);
        }
        if (isset($data['card'])) {
            $rel_card = $this->cardRepository->find($data['card']);
            if (!$rel_card) return $this->json(['error' => 'Card not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $draftPick->setCard($rel_card);
        }

        $errors = $this->validator->validate($draftPick);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($draftPick, flush: true);
        return $this->json($draftPick, context: ['groups' => ['draftPick:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(DraftPick $draftPick): JsonResponse
    {
        $this->repository->remove($draftPick, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/first-pick', name: 'isFirstPick', methods: ['GET'])]
    public function isFirstPick(DraftPick $draftPick): JsonResponse
    {
        $result = $draftPick->isFirstPick();
        $this->repository->save($draftPick, flush: true);
        return $this->json($result);
    }
}
