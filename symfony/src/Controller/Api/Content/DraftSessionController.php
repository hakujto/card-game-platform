<?php

namespace App\Controller\Api\Content;

use App\Entity\Content\DraftSession;
use App\Repository\Content\DraftSessionRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Cards\CardSet;
use App\Repository\Cards\CardSetRepository;

#[Route('/api/draft_sessions', name: 'draftSession_')]
class DraftSessionController extends AbstractController
{
    public function __construct(
        private DraftSessionRepository $repository,
        private ValidatorInterface $validator,
        private CardSetRepository $cardSetRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['draftSession:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $draftSession = new DraftSession();
        if (isset($data['status'])) $draftSession->setStatus($data['status']);
        if (isset($data['draftType'])) $draftSession->setDraftType($data['draftType']);
        if (isset($data['seats'])) $draftSession->setSeats($data['seats']);
        if (isset($data['createdAt'])) $draftSession->setCreatedAt(new \DateTime($data['createdAt']));
        if (isset($data['completedAt'])) $draftSession->setCompletedAt(new \DateTime($data['completedAt']));
        if (!isset($data['cardSet'])) return $this->json(['error' => 'cardSet is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_cardSet = $this->cardSetRepository->find($data['cardSet']);
        if (!$rel_cardSet) return $this->json(['error' => 'CardSet not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $draftSession->setCardSet($rel_cardSet);

        $errors = $this->validator->validate($draftSession);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($draftSession, flush: true);
        return $this->json($draftSession, Response::HTTP_CREATED, context: ['groups' => ['draftSession:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(DraftSession $draftSession): JsonResponse
    {
        return $this->json($draftSession, context: ['groups' => ['draftSession:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, DraftSession $draftSession): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['status'])) $draftSession->setStatus($data['status']);
        if (isset($data['draftType'])) $draftSession->setDraftType($data['draftType']);
        if (isset($data['seats'])) $draftSession->setSeats($data['seats']);
        if (isset($data['createdAt'])) $draftSession->setCreatedAt(new \DateTime($data['createdAt']));
        if (isset($data['completedAt'])) $draftSession->setCompletedAt(new \DateTime($data['completedAt']));
        if (isset($data['cardSet'])) {
            $rel_cardSet = $this->cardSetRepository->find($data['cardSet']);
            if (!$rel_cardSet) return $this->json(['error' => 'CardSet not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $draftSession->setCardSet($rel_cardSet);
        }

        $errors = $this->validator->validate($draftSession);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($draftSession, flush: true);
        return $this->json($draftSession, context: ['groups' => ['draftSession:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(DraftSession $draftSession): JsonResponse
    {
        $this->repository->remove($draftSession, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/start', name: 'start', methods: ['POST'])]
    public function start(DraftSession $draftSession): JsonResponse
    {
        $draftSession->start();
        $this->repository->save($draftSession, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/abandon', name: 'abandon', methods: ['POST'])]
    public function abandon(DraftSession $draftSession): JsonResponse
    {
        $draftSession->abandon();
        $this->repository->save($draftSession, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/complete', name: 'complete', methods: ['POST'])]
    public function complete(DraftSession $draftSession): JsonResponse
    {
        $draftSession->complete();
        $this->repository->save($draftSession, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
