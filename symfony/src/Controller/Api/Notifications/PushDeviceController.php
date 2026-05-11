<?php

namespace App\Controller\Api\Notifications;

use App\Entity\Notifications\PushDevice;
use App\Repository\Notifications\PushDeviceRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Players\Player;
use App\Repository\Players\PlayerRepository;

#[Route('/api/push_devices', name: 'pushDevice_')]
class PushDeviceController extends AbstractController
{
    public function __construct(
        private PushDeviceRepository $repository,
        private ValidatorInterface $validator,
        private PlayerRepository $playerRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['pushDevice:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $pushDevice = new PushDevice();
        if (isset($data['deviceToken'])) $pushDevice->setDeviceToken($data['deviceToken']);
        if (isset($data['platform'])) $pushDevice->setPlatform($data['platform']);
        if (isset($data['deviceName'])) $pushDevice->setDeviceName($data['deviceName']);
        if (isset($data['isActive'])) $pushDevice->setIsActive($data['isActive']);
        if (isset($data['registeredAt'])) $pushDevice->setRegisteredAt(new \DateTime($data['registeredAt']));
        if (isset($data['lastUsedAt'])) $pushDevice->setLastUsedAt(new \DateTime($data['lastUsedAt']));
        if (!isset($data['player'])) return $this->json(['error' => 'player is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_player = $this->playerRepository->find($data['player']);
        if (!$rel_player) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $pushDevice->setPlayer($rel_player);

        $errors = $this->validator->validate($pushDevice);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($pushDevice, flush: true);
        return $this->json($pushDevice, Response::HTTP_CREATED, context: ['groups' => ['pushDevice:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(PushDevice $pushDevice): JsonResponse
    {
        return $this->json($pushDevice, context: ['groups' => ['pushDevice:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, PushDevice $pushDevice): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['deviceToken'])) $pushDevice->setDeviceToken($data['deviceToken']);
        if (isset($data['platform'])) $pushDevice->setPlatform($data['platform']);
        if (isset($data['deviceName'])) $pushDevice->setDeviceName($data['deviceName']);
        if (isset($data['isActive'])) $pushDevice->setIsActive($data['isActive']);
        if (isset($data['registeredAt'])) $pushDevice->setRegisteredAt(new \DateTime($data['registeredAt']));
        if (isset($data['lastUsedAt'])) $pushDevice->setLastUsedAt(new \DateTime($data['lastUsedAt']));
        if (isset($data['player'])) {
            $rel_player = $this->playerRepository->find($data['player']);
            if (!$rel_player) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $pushDevice->setPlayer($rel_player);
        }

        $errors = $this->validator->validate($pushDevice);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($pushDevice, flush: true);
        return $this->json($pushDevice, context: ['groups' => ['pushDevice:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(PushDevice $pushDevice): JsonResponse
    {
        $this->repository->remove($pushDevice, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
