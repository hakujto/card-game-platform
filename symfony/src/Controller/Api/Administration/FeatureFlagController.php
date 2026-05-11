<?php

namespace App\Controller\Api\Administration;

use App\Entity\Administration\FeatureFlag;
use App\Repository\Administration\FeatureFlagRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;


#[Route('/api/feature_flags', name: 'featureFlag_')]
class FeatureFlagController extends AbstractController
{
    public function __construct(
        private FeatureFlagRepository $repository,
        private ValidatorInterface $validator,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['featureFlag:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $featureFlag = new FeatureFlag();
        if (isset($data['key'])) $featureFlag->setKey($data['key']);
        if (isset($data['isEnabled'])) $featureFlag->setIsEnabled($data['isEnabled']);
        if (isset($data['rolloutPercent'])) $featureFlag->setRolloutPercent($data['rolloutPercent']);
        if (isset($data['description'])) $featureFlag->setDescription($data['description']);
        if (isset($data['updatedAt'])) $featureFlag->setUpdatedAt(new \DateTime($data['updatedAt']));


        $errors = $this->validator->validate($featureFlag);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($featureFlag, flush: true);
        return $this->json($featureFlag, Response::HTTP_CREATED, context: ['groups' => ['featureFlag:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(FeatureFlag $featureFlag): JsonResponse
    {
        return $this->json($featureFlag, context: ['groups' => ['featureFlag:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, FeatureFlag $featureFlag): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['key'])) $featureFlag->setKey($data['key']);
        if (isset($data['isEnabled'])) $featureFlag->setIsEnabled($data['isEnabled']);
        if (isset($data['rolloutPercent'])) $featureFlag->setRolloutPercent($data['rolloutPercent']);
        if (isset($data['description'])) $featureFlag->setDescription($data['description']);
        if (isset($data['updatedAt'])) $featureFlag->setUpdatedAt(new \DateTime($data['updatedAt']));


        $errors = $this->validator->validate($featureFlag);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($featureFlag, flush: true);
        return $this->json($featureFlag, context: ['groups' => ['featureFlag:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(FeatureFlag $featureFlag): JsonResponse
    {
        $this->repository->remove($featureFlag, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
