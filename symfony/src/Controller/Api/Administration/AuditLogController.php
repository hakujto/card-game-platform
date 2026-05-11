<?php

namespace App\Controller\Api\Administration;

use App\Entity\Administration\AuditLog;
use App\Repository\Administration\AuditLogRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Players\Player;
use App\Repository\Players\PlayerRepository;

#[Route('/api/audit_logs', name: 'auditLog_')]
class AuditLogController extends AbstractController
{
    public function __construct(
        private AuditLogRepository $repository,
        private ValidatorInterface $validator,
        private PlayerRepository $playerRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['auditLog:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $auditLog = new AuditLog();
        if (isset($data['action'])) $auditLog->setAction($data['action']);
        if (isset($data['targetType'])) $auditLog->setTargetType($data['targetType']);
        if (isset($data['targetId'])) $auditLog->setTargetId($data['targetId']);
        if (isset($data['oldValue'])) $auditLog->setOldValue($data['oldValue']);
        if (isset($data['newValue'])) $auditLog->setNewValue($data['newValue']);
        if (isset($data['ipAddress'])) $auditLog->setIpAddress($data['ipAddress']);
        if (isset($data['createdAt'])) $auditLog->setCreatedAt(new \DateTime($data['createdAt']));
        if (!isset($data['admin'])) return $this->json(['error' => 'admin is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_admin = $this->playerRepository->find($data['admin']);
        if (!$rel_admin) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $auditLog->setAdmin($rel_admin);

        $errors = $this->validator->validate($auditLog);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($auditLog, flush: true);
        return $this->json($auditLog, Response::HTTP_CREATED, context: ['groups' => ['auditLog:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(AuditLog $auditLog): JsonResponse
    {
        return $this->json($auditLog, context: ['groups' => ['auditLog:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, AuditLog $auditLog): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['action'])) $auditLog->setAction($data['action']);
        if (isset($data['targetType'])) $auditLog->setTargetType($data['targetType']);
        if (isset($data['targetId'])) $auditLog->setTargetId($data['targetId']);
        if (isset($data['oldValue'])) $auditLog->setOldValue($data['oldValue']);
        if (isset($data['newValue'])) $auditLog->setNewValue($data['newValue']);
        if (isset($data['ipAddress'])) $auditLog->setIpAddress($data['ipAddress']);
        if (isset($data['createdAt'])) $auditLog->setCreatedAt(new \DateTime($data['createdAt']));
        if (isset($data['admin'])) {
            $rel_admin = $this->playerRepository->find($data['admin']);
            if (!$rel_admin) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $auditLog->setAdmin($rel_admin);
        }

        $errors = $this->validator->validate($auditLog);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($auditLog, flush: true);
        return $this->json($auditLog, context: ['groups' => ['auditLog:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(AuditLog $auditLog): JsonResponse
    {
        $this->repository->remove($auditLog, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
