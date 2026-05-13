<?php

namespace App\Controller\Api\Tournaments;

use App\Entity\Tournaments\Season;
use App\Repository\Tournaments\SeasonRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;


#[Route('/api/seasons', name: 'season_')]
class SeasonController extends AbstractController
{
    public function __construct(
        private SeasonRepository $repository,
        private ValidatorInterface $validator,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['season:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $season = new Season();
        if (isset($data['name'])) $season->setName($data['name']);
        if (isset($data['startDate'])) $season->setStartDate(new \DateTime($data['startDate']));
        if (isset($data['endDate'])) $season->setEndDate(new \DateTime($data['endDate']));
        if (isset($data['format'])) $season->setFormat($data['format']);
        if (isset($data['isActive'])) $season->setIsActive($data['isActive']);
        if (isset($data['rewardDescription'])) $season->setRewardDescription($data['rewardDescription']);


        $errors = $this->validator->validate($season);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($season, flush: true);
        return $this->json($season, Response::HTTP_CREATED, context: ['groups' => ['season:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(Season $season): JsonResponse
    {
        return $this->json($season, context: ['groups' => ['season:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, Season $season): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['name'])) $season->setName($data['name']);
        if (isset($data['startDate'])) $season->setStartDate(new \DateTime($data['startDate']));
        if (isset($data['endDate'])) $season->setEndDate(new \DateTime($data['endDate']));
        if (isset($data['format'])) $season->setFormat($data['format']);
        if (isset($data['isActive'])) $season->setIsActive($data['isActive']);
        if (isset($data['rewardDescription'])) $season->setRewardDescription($data['rewardDescription']);


        $errors = $this->validator->validate($season);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($season, flush: true);
        return $this->json($season, context: ['groups' => ['season:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(Season $season): JsonResponse
    {
        $this->repository->remove($season, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/activate', name: 'activate', methods: ['POST'])]
    public function activate(Season $season): JsonResponse
    {
        $season->activate();
        $this->repository->save($season, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/deactivate', name: 'deactivate', methods: ['POST'])]
    public function deactivate(Season $season): JsonResponse
    {
        $season->deactivate();
        $this->repository->save($season, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/finalize', name: 'finalizeRewards', methods: ['POST'])]
    public function finalizeRewards(Season $season): JsonResponse
    {
        $season->finalizeRewards();
        $this->repository->save($season, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
