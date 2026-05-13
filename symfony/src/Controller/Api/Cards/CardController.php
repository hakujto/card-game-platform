<?php

namespace App\Controller\Api\Cards;

use App\Entity\Cards\Card;
use App\Repository\Cards\CardRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Cards\CardSet;
use App\Repository\Cards\CardSetRepository;
use App\Entity\Cards\CardRuling;
use App\Repository\Cards\CardRulingRepository;
use App\Entity\Cards\CardAbility;
use App\Repository\Cards\CardAbilityRepository;

#[Route('/api/cards', name: 'card_')]
class CardController extends AbstractController
{
    public function __construct(
        private CardRepository $repository,
        private ValidatorInterface $validator,
        private CardSetRepository $cardSetRepository,
        private CardRulingRepository $cardRulingRepository,
        private CardAbilityRepository $cardAbilityRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['card:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $card = new Card();
        if (isset($data['name'])) $card->setName($data['name']);
        if (isset($data['cardType'])) $card->setCardType($data['cardType']);
        if (isset($data['rarity'])) $card->setRarity($data['rarity']);
        if (isset($data['manaCost'])) $card->setManaCost($data['manaCost']);
        if (isset($data['manaColors'])) $card->setManaColors($data['manaColors']);
        if (isset($data['attack'])) $card->setAttack($data['attack']);
        if (isset($data['defense'])) $card->setDefense($data['defense']);
        if (isset($data['loyalty'])) $card->setLoyalty($data['loyalty']);
        if (isset($data['description'])) $card->setDescription($data['description']);
        if (isset($data['flavorText'])) $card->setFlavorText($data['flavorText']);
        if (isset($data['imageUrl'])) $card->setImageUrl($data['imageUrl']);
        if (isset($data['artistName'])) $card->setArtistName($data['artistName']);
        if (isset($data['legalFormats'])) $card->setLegalFormats($data['legalFormats']);
        if (isset($data['isBanned'])) $card->setIsBanned($data['isBanned']);
        if (isset($data['isRestricted'])) $card->setIsRestricted($data['isRestricted']);
        if (isset($data['powerLevel'])) $card->setPowerLevel($data['powerLevel']);
        if (!isset($data['set'])) return $this->json(['error' => 'set is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_set = $this->cardSetRepository->find($data['set']);
        if (!$rel_set) return $this->json(['error' => 'CardSet not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $card->setSet($rel_set);
        if (array_key_exists('rulings', $data)) {
            $card->setRulings($data['rulings'] !== null ? $this->cardRulingRepository->find($data['rulings']) : null);
        }
        if (array_key_exists('abilities', $data)) {
            $card->setAbilities($data['abilities'] !== null ? $this->cardAbilityRepository->find($data['abilities']) : null);
        }

        $errors = $this->validator->validate($card);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($card, flush: true);
        return $this->json($card, Response::HTTP_CREATED, context: ['groups' => ['card:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(Card $card): JsonResponse
    {
        return $this->json($card, context: ['groups' => ['card:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, Card $card): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['name'])) $card->setName($data['name']);
        if (isset($data['cardType'])) $card->setCardType($data['cardType']);
        if (isset($data['rarity'])) $card->setRarity($data['rarity']);
        if (isset($data['manaCost'])) $card->setManaCost($data['manaCost']);
        if (isset($data['manaColors'])) $card->setManaColors($data['manaColors']);
        if (isset($data['attack'])) $card->setAttack($data['attack']);
        if (isset($data['defense'])) $card->setDefense($data['defense']);
        if (isset($data['loyalty'])) $card->setLoyalty($data['loyalty']);
        if (isset($data['description'])) $card->setDescription($data['description']);
        if (isset($data['flavorText'])) $card->setFlavorText($data['flavorText']);
        if (isset($data['imageUrl'])) $card->setImageUrl($data['imageUrl']);
        if (isset($data['artistName'])) $card->setArtistName($data['artistName']);
        if (isset($data['legalFormats'])) $card->setLegalFormats($data['legalFormats']);
        if (isset($data['isBanned'])) $card->setIsBanned($data['isBanned']);
        if (isset($data['isRestricted'])) $card->setIsRestricted($data['isRestricted']);
        if (isset($data['powerLevel'])) $card->setPowerLevel($data['powerLevel']);
        if (isset($data['set'])) {
            $rel_set = $this->cardSetRepository->find($data['set']);
            if (!$rel_set) return $this->json(['error' => 'CardSet not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $card->setSet($rel_set);
        }
        if (array_key_exists('rulings', $data)) {
            $card->setRulings($data['rulings'] !== null ? $this->cardRulingRepository->find($data['rulings']) : null);
        }
        if (array_key_exists('abilities', $data)) {
            $card->setAbilities($data['abilities'] !== null ? $this->cardAbilityRepository->find($data['abilities']) : null);
        }

        $errors = $this->validator->validate($card);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($card, flush: true);
        return $this->json($card, context: ['groups' => ['card:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(Card $card): JsonResponse
    {
        $this->repository->remove($card, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/ban', name: 'ban', methods: ['POST'])]
    public function ban(Card $card): JsonResponse
    {
        $card->ban();
        $this->repository->save($card, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/unban', name: 'unban', methods: ['POST'])]
    public function unban(Card $card): JsonResponse
    {
        $card->unban();
        $this->repository->save($card, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/restrict', name: 'restrict', methods: ['POST'])]
    public function restrict(Card $card): JsonResponse
    {
        $card->restrict();
        $this->repository->save($card, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/unrestrict', name: 'unrestrict', methods: ['POST'])]
    public function unrestrict(Card $card): JsonResponse
    {
        $card->unrestrict();
        $this->repository->save($card, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/value', name: 'calculateValue', methods: ['GET'])]
    public function calculateValue(Card $card): JsonResponse
    {
        $result = $card->calculateValue();
        $this->repository->save($card, flush: true);
        return $this->json($result);
    }
}
