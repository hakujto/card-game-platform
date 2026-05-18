<?php

namespace App\Controller\Api\Players;

use App\Entity\Players\Achievement;
use App\Repository\Players\AchievementRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;


#[Route('/api/achievements', name: 'achievement_')]
class AchievementController extends AbstractController
{
    public function __construct(
        private AchievementRepository $repository,
        private ValidatorInterface $validator,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['achievement:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $achievement = new Achievement();
        if (isset($data['name'])) $achievement->setName($data['name']);
        if (isset($data['description'])) $achievement->setDescription($data['description']);
        if (isset($data['iconUrl'])) $achievement->setIconUrl($data['iconUrl']);
        if (isset($data['points'])) $achievement->setPoints($data['points']);
        if (isset($data['rarity'])) $achievement->setRarity($data['rarity']);
        if (isset($data['isHidden'])) $achievement->setIsHidden($data['isHidden']);


        $errors = $this->validator->validate($achievement);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($achievement, flush: true);
        return $this->json($achievement, Response::HTTP_CREATED, context: ['groups' => ['achievement:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(Achievement $achievement): JsonResponse
    {
        return $this->json($achievement, context: ['groups' => ['achievement:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, Achievement $achievement): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['name'])) $achievement->setName($data['name']);
        if (isset($data['description'])) $achievement->setDescription($data['description']);
        if (isset($data['iconUrl'])) $achievement->setIconUrl($data['iconUrl']);
        if (isset($data['points'])) $achievement->setPoints($data['points']);
        if (isset($data['rarity'])) $achievement->setRarity($data['rarity']);
        if (isset($data['isHidden'])) $achievement->setIsHidden($data['isHidden']);


        $errors = $this->validator->validate($achievement);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($achievement, flush: true);
        return $this->json($achievement, context: ['groups' => ['achievement:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(Achievement $achievement): JsonResponse
    {
        $this->repository->remove($achievement, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/point-value', name: 'pointValue', methods: ['GET'])]
    public function pointValue(Achievement $achievement): JsonResponse
    {
        $result = $achievement->pointValue($multiplier);
        $this->repository->save($achievement, flush: true);
        return $this->json($result);
    }

    #[Route('/{id}/reveal', name: 'reveal', methods: ['POST'])]
    public function reveal(Achievement $achievement): JsonResponse
    {
        $achievement->reveal();
        $this->repository->save($achievement, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
