<?php

namespace App\Controller\Api\Cards;

use App\Entity\Cards\DeckTag;
use App\Repository\Cards\DeckTagRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;


#[Route('/api/deck_tags', name: 'deckTag_')]
class DeckTagController extends AbstractController
{
    public function __construct(
        private DeckTagRepository $repository,
        private ValidatorInterface $validator,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['deckTag:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $deckTag = new DeckTag();
        if (isset($data['name'])) $deckTag->setName($data['name']);
        if (isset($data['color'])) $deckTag->setColor($data['color']);


        $errors = $this->validator->validate($deckTag);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($deckTag, flush: true);
        return $this->json($deckTag, Response::HTTP_CREATED, context: ['groups' => ['deckTag:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(DeckTag $deckTag): JsonResponse
    {
        return $this->json($deckTag, context: ['groups' => ['deckTag:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, DeckTag $deckTag): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['name'])) $deckTag->setName($data['name']);
        if (isset($data['color'])) $deckTag->setColor($data['color']);


        $errors = $this->validator->validate($deckTag);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($deckTag, flush: true);
        return $this->json($deckTag, context: ['groups' => ['deckTag:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(DeckTag $deckTag): JsonResponse
    {
        $this->repository->remove($deckTag, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
