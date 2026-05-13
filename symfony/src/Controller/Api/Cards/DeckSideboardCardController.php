<?php

namespace App\Controller\Api\Cards;

use App\Entity\Cards\DeckSideboardCard;
use App\Repository\Cards\DeckSideboardCardRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Cards\Deck;
use App\Repository\Cards\DeckRepository;
use App\Entity\Cards\Card;
use App\Repository\Cards\CardRepository;

#[Route('/api/deck_sideboard_cards', name: 'deckSideboardCard_')]
class DeckSideboardCardController extends AbstractController
{
    public function __construct(
        private DeckSideboardCardRepository $repository,
        private ValidatorInterface $validator,
        private DeckRepository $deckRepository,
        private CardRepository $cardRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['deckSideboardCard:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $deckSideboardCard = new DeckSideboardCard();
        if (isset($data['quantity'])) $deckSideboardCard->setQuantity($data['quantity']);
        if (!isset($data['deck'])) return $this->json(['error' => 'deck is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_deck = $this->deckRepository->find($data['deck']);
        if (!$rel_deck) return $this->json(['error' => 'Deck not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $deckSideboardCard->setDeck($rel_deck);
        if (!isset($data['card'])) return $this->json(['error' => 'card is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_card = $this->cardRepository->find($data['card']);
        if (!$rel_card) return $this->json(['error' => 'Card not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $deckSideboardCard->setCard($rel_card);

        $errors = $this->validator->validate($deckSideboardCard);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($deckSideboardCard, flush: true);
        return $this->json($deckSideboardCard, Response::HTTP_CREATED, context: ['groups' => ['deckSideboardCard:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(DeckSideboardCard $deckSideboardCard): JsonResponse
    {
        return $this->json($deckSideboardCard, context: ['groups' => ['deckSideboardCard:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, DeckSideboardCard $deckSideboardCard): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['quantity'])) $deckSideboardCard->setQuantity($data['quantity']);
        if (isset($data['deck'])) {
            $rel_deck = $this->deckRepository->find($data['deck']);
            if (!$rel_deck) return $this->json(['error' => 'Deck not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $deckSideboardCard->setDeck($rel_deck);
        }
        if (isset($data['card'])) {
            $rel_card = $this->cardRepository->find($data['card']);
            if (!$rel_card) return $this->json(['error' => 'Card not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $deckSideboardCard->setCard($rel_card);
        }

        $errors = $this->validator->validate($deckSideboardCard);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($deckSideboardCard, flush: true);
        return $this->json($deckSideboardCard, context: ['groups' => ['deckSideboardCard:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(DeckSideboardCard $deckSideboardCard): JsonResponse
    {
        $this->repository->remove($deckSideboardCard, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

}
