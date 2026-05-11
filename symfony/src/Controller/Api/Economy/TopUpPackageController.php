<?php

namespace App\Controller\Api\Economy;

use App\Entity\Economy\TopUpPackage;
use App\Repository\Economy\TopUpPackageRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;


#[Route('/api/top_up_packages', name: 'topUpPackage_')]
class TopUpPackageController extends AbstractController
{
    public function __construct(
        private TopUpPackageRepository $repository,
        private ValidatorInterface $validator,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['topUpPackage:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $topUpPackage = new TopUpPackage();
        if (isset($data['name'])) $topUpPackage->setName($data['name']);
        if (isset($data['price'])) $topUpPackage->setPrice($data['price']);
        if (isset($data['currency'])) $topUpPackage->setCurrency($data['currency']);
        if (isset($data['creditsAmount'])) $topUpPackage->setCreditsAmount($data['creditsAmount']);
        if (isset($data['gemsAmount'])) $topUpPackage->setGemsAmount($data['gemsAmount']);
        if (isset($data['bonusPercent'])) $topUpPackage->setBonusPercent($data['bonusPercent']);
        if (isset($data['isActive'])) $topUpPackage->setIsActive($data['isActive']);
        if (isset($data['featured'])) $topUpPackage->setFeatured($data['featured']);


        $errors = $this->validator->validate($topUpPackage);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($topUpPackage, flush: true);
        return $this->json($topUpPackage, Response::HTTP_CREATED, context: ['groups' => ['topUpPackage:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(TopUpPackage $topUpPackage): JsonResponse
    {
        return $this->json($topUpPackage, context: ['groups' => ['topUpPackage:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, TopUpPackage $topUpPackage): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['name'])) $topUpPackage->setName($data['name']);
        if (isset($data['price'])) $topUpPackage->setPrice($data['price']);
        if (isset($data['currency'])) $topUpPackage->setCurrency($data['currency']);
        if (isset($data['creditsAmount'])) $topUpPackage->setCreditsAmount($data['creditsAmount']);
        if (isset($data['gemsAmount'])) $topUpPackage->setGemsAmount($data['gemsAmount']);
        if (isset($data['bonusPercent'])) $topUpPackage->setBonusPercent($data['bonusPercent']);
        if (isset($data['isActive'])) $topUpPackage->setIsActive($data['isActive']);
        if (isset($data['featured'])) $topUpPackage->setFeatured($data['featured']);


        $errors = $this->validator->validate($topUpPackage);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($topUpPackage, flush: true);
        return $this->json($topUpPackage, context: ['groups' => ['topUpPackage:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(TopUpPackage $topUpPackage): JsonResponse
    {
        $this->repository->remove($topUpPackage, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
