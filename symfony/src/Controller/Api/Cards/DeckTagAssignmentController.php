<?php

namespace App\Controller\Api\Cards;

use App\Entity\Cards\DeckTagAssignment;
use App\Repository\Cards\DeckTagAssignmentRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Cards\Deck;
use App\Repository\Cards\DeckRepository;
use App\Entity\Cards\DeckTag;
use App\Repository\Cards\DeckTagRepository;

#[Route('/api/deck_tag_assignments', name: 'deckTagAssignment_')]
class DeckTagAssignmentController extends AbstractController
{
    public function __construct(
        private DeckTagAssignmentRepository $repository,
        private ValidatorInterface $validator,
        private DeckRepository $deckRepository,
        private DeckTagRepository $deckTagRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['deckTagAssignment:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $deckTagAssignment = new DeckTagAssignment();

        if (!isset($data['deck'])) return $this->json(['error' => 'deck is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_deck = $this->deckRepository->find($data['deck']);
        if (!$rel_deck) return $this->json(['error' => 'Deck not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $deckTagAssignment->setDeck($rel_deck);
        if (!isset($data['tag'])) return $this->json(['error' => 'tag is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_tag = $this->deckTagRepository->find($data['tag']);
        if (!$rel_tag) return $this->json(['error' => 'DeckTag not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $deckTagAssignment->setTag($rel_tag);

        $errors = $this->validator->validate($deckTagAssignment);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($deckTagAssignment, flush: true);
        return $this->json($deckTagAssignment, Response::HTTP_CREATED, context: ['groups' => ['deckTagAssignment:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(DeckTagAssignment $deckTagAssignment): JsonResponse
    {
        return $this->json($deckTagAssignment, context: ['groups' => ['deckTagAssignment:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, DeckTagAssignment $deckTagAssignment): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];

        if (isset($data['deck'])) {
            $rel_deck = $this->deckRepository->find($data['deck']);
            if (!$rel_deck) return $this->json(['error' => 'Deck not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $deckTagAssignment->setDeck($rel_deck);
        }
        if (isset($data['tag'])) {
            $rel_tag = $this->deckTagRepository->find($data['tag']);
            if (!$rel_tag) return $this->json(['error' => 'DeckTag not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $deckTagAssignment->setTag($rel_tag);
        }

        $errors = $this->validator->validate($deckTagAssignment);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($deckTagAssignment, flush: true);
        return $this->json($deckTagAssignment, context: ['groups' => ['deckTagAssignment:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(DeckTagAssignment $deckTagAssignment): JsonResponse
    {
        $this->repository->remove($deckTagAssignment, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

}
