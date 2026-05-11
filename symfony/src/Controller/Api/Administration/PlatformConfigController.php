<?php

namespace App\Controller\Api\Administration;

use App\Entity\Administration\PlatformConfig;
use App\Repository\Administration\PlatformConfigRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Players\Player;
use App\Repository\Players\PlayerRepository;

#[Route('/api/platform_configs', name: 'platformConfig_')]
class PlatformConfigController extends AbstractController
{
    public function __construct(
        private PlatformConfigRepository $repository,
        private ValidatorInterface $validator,
        private PlayerRepository $playerRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['platformConfig:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $platformConfig = new PlatformConfig();
        if (isset($data['configKey'])) $platformConfig->setConfigKey($data['configKey']);
        if (isset($data['configValue'])) $platformConfig->setConfigValue($data['configValue']);
        if (isset($data['valueType'])) $platformConfig->setValueType($data['valueType']);
        if (isset($data['description'])) $platformConfig->setDescription($data['description']);
        if (isset($data['updatedAt'])) $platformConfig->setUpdatedAt(new \DateTime($data['updatedAt']));
        if (!isset($data['updatedBy'])) return $this->json(['error' => 'updatedBy is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_updatedBy = $this->playerRepository->find($data['updatedBy']);
        if (!$rel_updatedBy) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $platformConfig->setUpdatedBy($rel_updatedBy);

        $errors = $this->validator->validate($platformConfig);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($platformConfig, flush: true);
        return $this->json($platformConfig, Response::HTTP_CREATED, context: ['groups' => ['platformConfig:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(PlatformConfig $platformConfig): JsonResponse
    {
        return $this->json($platformConfig, context: ['groups' => ['platformConfig:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, PlatformConfig $platformConfig): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['configKey'])) $platformConfig->setConfigKey($data['configKey']);
        if (isset($data['configValue'])) $platformConfig->setConfigValue($data['configValue']);
        if (isset($data['valueType'])) $platformConfig->setValueType($data['valueType']);
        if (isset($data['description'])) $platformConfig->setDescription($data['description']);
        if (isset($data['updatedAt'])) $platformConfig->setUpdatedAt(new \DateTime($data['updatedAt']));
        if (isset($data['updatedBy'])) {
            $rel_updatedBy = $this->playerRepository->find($data['updatedBy']);
            if (!$rel_updatedBy) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $platformConfig->setUpdatedBy($rel_updatedBy);
        }

        $errors = $this->validator->validate($platformConfig);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($platformConfig, flush: true);
        return $this->json($platformConfig, context: ['groups' => ['platformConfig:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(PlatformConfig $platformConfig): JsonResponse
    {
        $this->repository->remove($platformConfig, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
