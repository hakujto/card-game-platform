<?php

namespace App\Controller\Api\Content;

use App\Entity\Content\DeckReview;
use App\Repository\Content\DeckReviewRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Cards\Deck;
use App\Repository\Cards\DeckRepository;
use App\Entity\Players\Player;
use App\Repository\Players\PlayerRepository;

#[Route('/api/deck_reviews', name: 'deckReview_')]
class DeckReviewController extends AbstractController
{
    public function __construct(
        private DeckReviewRepository $repository,
        private ValidatorInterface $validator,
        private DeckRepository $deckRepository,
        private PlayerRepository $playerRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['deckReview:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $deckReview = new DeckReview();
        if (isset($data['rating'])) $deckReview->setRating($data['rating']);
        if (isset($data['body'])) $deckReview->setBody($data['body']);
        if (isset($data['createdAt'])) $deckReview->setCreatedAt(new \DateTime($data['createdAt']));
        if (isset($data['updatedAt'])) $deckReview->setUpdatedAt(new \DateTime($data['updatedAt']));
        if (!isset($data['deck'])) return $this->json(['error' => 'deck is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_deck = $this->deckRepository->find($data['deck']);
        if (!$rel_deck) return $this->json(['error' => 'Deck not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $deckReview->setDeck($rel_deck);
        if (!isset($data['author'])) return $this->json(['error' => 'author is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_author = $this->playerRepository->find($data['author']);
        if (!$rel_author) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $deckReview->setAuthor($rel_author);

        $errors = $this->validator->validate($deckReview);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($deckReview, flush: true);
        return $this->json($deckReview, Response::HTTP_CREATED, context: ['groups' => ['deckReview:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(DeckReview $deckReview): JsonResponse
    {
        return $this->json($deckReview, context: ['groups' => ['deckReview:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, DeckReview $deckReview): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['rating'])) $deckReview->setRating($data['rating']);
        if (isset($data['body'])) $deckReview->setBody($data['body']);
        if (isset($data['createdAt'])) $deckReview->setCreatedAt(new \DateTime($data['createdAt']));
        if (isset($data['updatedAt'])) $deckReview->setUpdatedAt(new \DateTime($data['updatedAt']));
        if (isset($data['deck'])) {
            $rel_deck = $this->deckRepository->find($data['deck']);
            if (!$rel_deck) return $this->json(['error' => 'Deck not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $deckReview->setDeck($rel_deck);
        }
        if (isset($data['author'])) {
            $rel_author = $this->playerRepository->find($data['author']);
            if (!$rel_author) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $deckReview->setAuthor($rel_author);
        }

        $errors = $this->validator->validate($deckReview);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($deckReview, flush: true);
        return $this->json($deckReview, context: ['groups' => ['deckReview:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(DeckReview $deckReview): JsonResponse
    {
        $this->repository->remove($deckReview, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
