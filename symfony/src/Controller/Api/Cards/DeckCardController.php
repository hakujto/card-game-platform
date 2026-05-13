<?php

namespace App\Controller\Api\Cards;

use App\Entity\Cards\DeckCard;
use App\Repository\Cards\DeckCardRepository;
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

#[Route('/api/deck_cards', name: 'deckCard_')]
class DeckCardController extends AbstractController
{
    public function __construct(
        private DeckCardRepository $repository,
        private ValidatorInterface $validator,
        private DeckRepository $deckRepository,
        private CardRepository $cardRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['deckCard:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $deckCard = new DeckCard();
        if (isset($data['quantity'])) $deckCard->setQuantity($data['quantity']);
        if (isset($data['isCommander'])) $deckCard->setIsCommander($data['isCommander']);
        if (!isset($data['deck'])) return $this->json(['error' => 'deck is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_deck = $this->deckRepository->find($data['deck']);
        if (!$rel_deck) return $this->json(['error' => 'Deck not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $deckCard->setDeck($rel_deck);
        if (!isset($data['card'])) return $this->json(['error' => 'card is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_card = $this->cardRepository->find($data['card']);
        if (!$rel_card) return $this->json(['error' => 'Card not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $deckCard->setCard($rel_card);

        $errors = $this->validator->validate($deckCard);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($deckCard, flush: true);
        return $this->json($deckCard, Response::HTTP_CREATED, context: ['groups' => ['deckCard:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(DeckCard $deckCard): JsonResponse
    {
        return $this->json($deckCard, context: ['groups' => ['deckCard:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, DeckCard $deckCard): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['quantity'])) $deckCard->setQuantity($data['quantity']);
        if (isset($data['isCommander'])) $deckCard->setIsCommander($data['isCommander']);
        if (isset($data['deck'])) {
            $rel_deck = $this->deckRepository->find($data['deck']);
            if (!$rel_deck) return $this->json(['error' => 'Deck not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $deckCard->setDeck($rel_deck);
        }
        if (isset($data['card'])) {
            $rel_card = $this->cardRepository->find($data['card']);
            if (!$rel_card) return $this->json(['error' => 'Card not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $deckCard->setCard($rel_card);
        }

        $errors = $this->validator->validate($deckCard);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($deckCard, flush: true);
        return $this->json($deckCard, context: ['groups' => ['deckCard:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(DeckCard $deckCard): JsonResponse
    {
        $this->repository->remove($deckCard, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

}
