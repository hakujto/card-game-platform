<?php

namespace App\Controller\Api\Administration;

use App\Entity\Administration\SystemAnnouncement;
use App\Repository\Administration\SystemAnnouncementRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;


#[Route('/api/system_announcements', name: 'systemAnnouncement_')]
class SystemAnnouncementController extends AbstractController
{
    public function __construct(
        private SystemAnnouncementRepository $repository,
        private ValidatorInterface $validator,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['systemAnnouncement:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $systemAnnouncement = new SystemAnnouncement();
        if (isset($data['title'])) $systemAnnouncement->setTitle($data['title']);
        if (isset($data['body'])) $systemAnnouncement->setBody($data['body']);
        if (isset($data['announcementType'])) $systemAnnouncement->setAnnouncementType($data['announcementType']);
        if (isset($data['severity'])) $systemAnnouncement->setSeverity($data['severity']);
        if (isset($data['isActive'])) $systemAnnouncement->setIsActive($data['isActive']);
        if (isset($data['showFrom'])) $systemAnnouncement->setShowFrom(new \DateTime($data['showFrom']));
        if (isset($data['showUntil'])) $systemAnnouncement->setShowUntil(new \DateTime($data['showUntil']));
        if (isset($data['createdAt'])) $systemAnnouncement->setCreatedAt(new \DateTime($data['createdAt']));


        $errors = $this->validator->validate($systemAnnouncement);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($systemAnnouncement, flush: true);
        return $this->json($systemAnnouncement, Response::HTTP_CREATED, context: ['groups' => ['systemAnnouncement:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(SystemAnnouncement $systemAnnouncement): JsonResponse
    {
        return $this->json($systemAnnouncement, context: ['groups' => ['systemAnnouncement:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, SystemAnnouncement $systemAnnouncement): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['title'])) $systemAnnouncement->setTitle($data['title']);
        if (isset($data['body'])) $systemAnnouncement->setBody($data['body']);
        if (isset($data['announcementType'])) $systemAnnouncement->setAnnouncementType($data['announcementType']);
        if (isset($data['severity'])) $systemAnnouncement->setSeverity($data['severity']);
        if (isset($data['isActive'])) $systemAnnouncement->setIsActive($data['isActive']);
        if (isset($data['showFrom'])) $systemAnnouncement->setShowFrom(new \DateTime($data['showFrom']));
        if (isset($data['showUntil'])) $systemAnnouncement->setShowUntil(new \DateTime($data['showUntil']));
        if (isset($data['createdAt'])) $systemAnnouncement->setCreatedAt(new \DateTime($data['createdAt']));


        $errors = $this->validator->validate($systemAnnouncement);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($systemAnnouncement, flush: true);
        return $this->json($systemAnnouncement, context: ['groups' => ['systemAnnouncement:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(SystemAnnouncement $systemAnnouncement): JsonResponse
    {
        $this->repository->remove($systemAnnouncement, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
