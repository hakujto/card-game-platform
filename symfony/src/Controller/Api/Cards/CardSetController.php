<?php

namespace App\Controller\Api\Cards;

use App\Entity\Cards\CardSet;
use App\Repository\Cards\CardSetRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;


#[Route('/api/card_sets', name: 'cardSet_')]
class CardSetController extends AbstractController
{
    public function __construct(
        private CardSetRepository $repository,
        private ValidatorInterface $validator,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['cardSet:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $cardSet = new CardSet();
        if (isset($data['name'])) $cardSet->setName($data['name']);
        if (isset($data['code'])) $cardSet->setCode($data['code']);
        if (isset($data['releaseDate'])) $cardSet->setReleaseDate(new \DateTime($data['releaseDate']));
        if (isset($data['rotationDate'])) $cardSet->setRotationDate(new \DateTime($data['rotationDate']));
        if (isset($data['setType'])) $cardSet->setSetType($data['setType']);
        if (isset($data['totalCards'])) $cardSet->setTotalCards($data['totalCards']);
        if (isset($data['isRotated'])) $cardSet->setIsRotated($data['isRotated']);
        if (isset($data['description'])) $cardSet->setDescription($data['description']);
        if (isset($data['logoUrl'])) $cardSet->setLogoUrl($data['logoUrl']);


        $errors = $this->validator->validate($cardSet);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        try {
            $cardSet->validateImplies();
        } catch (\DomainException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($cardSet, flush: true);
        return $this->json($cardSet, Response::HTTP_CREATED, context: ['groups' => ['cardSet:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(CardSet $cardSet): JsonResponse
    {
        return $this->json($cardSet, context: ['groups' => ['cardSet:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, CardSet $cardSet): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['name'])) $cardSet->setName($data['name']);
        if (isset($data['code'])) $cardSet->setCode($data['code']);
        if (isset($data['releaseDate'])) $cardSet->setReleaseDate(new \DateTime($data['releaseDate']));
        if (isset($data['rotationDate'])) $cardSet->setRotationDate(new \DateTime($data['rotationDate']));
        if (isset($data['setType'])) $cardSet->setSetType($data['setType']);
        if (isset($data['totalCards'])) $cardSet->setTotalCards($data['totalCards']);
        if (isset($data['isRotated'])) $cardSet->setIsRotated($data['isRotated']);
        if (isset($data['description'])) $cardSet->setDescription($data['description']);
        if (isset($data['logoUrl'])) $cardSet->setLogoUrl($data['logoUrl']);


        $errors = $this->validator->validate($cardSet);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        try {
            $cardSet->validateImplies();
        } catch (\DomainException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($cardSet, flush: true);
        return $this->json($cardSet, context: ['groups' => ['cardSet:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(CardSet $cardSet): JsonResponse
    {
        $this->repository->remove($cardSet, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/standard-legal', name: 'isLegalInStandard', methods: ['GET'])]
    public function isLegalInStandard(CardSet $cardSet): JsonResponse
    {
        $result = $cardSet->isLegalInStandard();
        $this->repository->save($cardSet, flush: true);
        return $this->json($result);
    }

    #[Route('/{id}/legal', name: 'isLegalInFormat', methods: ['GET'])]
    public function isLegalInFormat(CardSet $cardSet): JsonResponse
    {
        $result = $cardSet->isLegalInFormat($format);
        $this->repository->save($cardSet, flush: true);
        return $this->json($result);
    }

    #[Route('/{id}/rarity-count', name: 'cardCountByRarity', methods: ['GET'])]
    public function cardCountByRarity(CardSet $cardSet): JsonResponse
    {
        $result = $cardSet->cardCountByRarity($rarity);
        $this->repository->save($cardSet, flush: true);
        return $this->json($result);
    }

    #[Route('/{id}/rotate', name: 'rotateOut', methods: ['POST'])]
    public function rotateOut(CardSet $cardSet): JsonResponse
    {
        $cardSet->rotateOut();
        $this->repository->save($cardSet, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
