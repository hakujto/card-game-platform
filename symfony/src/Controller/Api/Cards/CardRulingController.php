<?php

namespace App\Controller\Api\Cards;

use App\Entity\Cards\CardRuling;
use App\Repository\Cards\CardRulingRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Cards\Card;
use App\Repository\Cards\CardRepository;

#[Route('/api/card_rulings', name: 'cardRuling_')]
class CardRulingController extends AbstractController
{
    public function __construct(
        private CardRulingRepository $repository,
        private ValidatorInterface $validator,
        private CardRepository $cardRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['cardRuling:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $cardRuling = new CardRuling();
        if (isset($data['rulingText'])) $cardRuling->setRulingText($data['rulingText']);
        if (isset($data['publishedAt'])) $cardRuling->setPublishedAt(new \DateTime($data['publishedAt']));
        if (isset($data['source'])) $cardRuling->setSource($data['source']);
        if (!isset($data['card'])) return $this->json(['error' => 'card is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_card = $this->cardRepository->find($data['card']);
        if (!$rel_card) return $this->json(['error' => 'Card not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $cardRuling->setCard($rel_card);

        $errors = $this->validator->validate($cardRuling);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($cardRuling, flush: true);
        return $this->json($cardRuling, Response::HTTP_CREATED, context: ['groups' => ['cardRuling:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(CardRuling $cardRuling): JsonResponse
    {
        return $this->json($cardRuling, context: ['groups' => ['cardRuling:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, CardRuling $cardRuling): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['rulingText'])) $cardRuling->setRulingText($data['rulingText']);
        if (isset($data['publishedAt'])) $cardRuling->setPublishedAt(new \DateTime($data['publishedAt']));
        if (isset($data['source'])) $cardRuling->setSource($data['source']);
        if (isset($data['card'])) {
            $rel_card = $this->cardRepository->find($data['card']);
            if (!$rel_card) return $this->json(['error' => 'Card not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $cardRuling->setCard($rel_card);
        }

        $errors = $this->validator->validate($cardRuling);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($cardRuling, flush: true);
        return $this->json($cardRuling, context: ['groups' => ['cardRuling:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(CardRuling $cardRuling): JsonResponse
    {
        $this->repository->remove($cardRuling, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
