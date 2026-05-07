<?php

namespace App\Controller\Api\Players;

use App\Entity\Players\Friendship;
use App\Repository\Players\FriendshipRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Players\Player;
use App\Repository\Players\PlayerRepository;

#[Route('/api/friendships', name: 'friendship_')]
class FriendshipController extends AbstractController
{
    public function __construct(
        private FriendshipRepository $repository,
        private ValidatorInterface $validator,
        private PlayerRepository $playerRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['friendship:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $friendship = new Friendship();
        if (isset($data['status'])) $friendship->setStatus($data['status']);
        if (isset($data['createdAt'])) $friendship->setCreatedAt(new \DateTime($data['createdAt']));
        if (!isset($data['requester'])) return $this->json(['error' => 'requester is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_requester = $this->playerRepository->find($data['requester']);
        if (!$rel_requester) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $friendship->setRequester($rel_requester);
        if (!isset($data['receiver'])) return $this->json(['error' => 'receiver is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_receiver = $this->playerRepository->find($data['receiver']);
        if (!$rel_receiver) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $friendship->setReceiver($rel_receiver);

        $errors = $this->validator->validate($friendship);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($friendship, flush: true);
        return $this->json($friendship, Response::HTTP_CREATED, context: ['groups' => ['friendship:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(Friendship $friendship): JsonResponse
    {
        return $this->json($friendship, context: ['groups' => ['friendship:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, Friendship $friendship): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['status'])) $friendship->setStatus($data['status']);
        if (isset($data['createdAt'])) $friendship->setCreatedAt(new \DateTime($data['createdAt']));
        if (isset($data['requester'])) {
            $rel_requester = $this->playerRepository->find($data['requester']);
            if (!$rel_requester) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $friendship->setRequester($rel_requester);
        }
        if (isset($data['receiver'])) {
            $rel_receiver = $this->playerRepository->find($data['receiver']);
            if (!$rel_receiver) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $friendship->setReceiver($rel_receiver);
        }

        $errors = $this->validator->validate($friendship);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($friendship, flush: true);
        return $this->json($friendship, context: ['groups' => ['friendship:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(Friendship $friendship): JsonResponse
    {
        $this->repository->remove($friendship, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
