<?php

namespace App\Controller\Api\Moderation;

use App\Entity\Moderation\ContentReport;
use App\Repository\Moderation\ContentReportRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Players\Player;
use App\Repository\Players\PlayerRepository;
use App\Entity\Content\Article;
use App\Repository\Content\ArticleRepository;
use App\Entity\Content\ArticleComment;
use App\Repository\Content\ArticleCommentRepository;

#[Route('/api/content_reports', name: 'contentReport_')]
class ContentReportController extends AbstractController
{
    public function __construct(
        private ContentReportRepository $repository,
        private ValidatorInterface $validator,
        private PlayerRepository $playerRepository,
        private ArticleRepository $articleRepository,
        private ArticleCommentRepository $articleCommentRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['contentReport:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $contentReport = new ContentReport();
        if (isset($data['targetType'])) $contentReport->setTargetType($data['targetType']);
        if (isset($data['reason'])) $contentReport->setReason($data['reason']);
        if (isset($data['description'])) $contentReport->setDescription($data['description']);
        if (isset($data['status'])) $contentReport->setStatus($data['status']);
        if (isset($data['createdAt'])) $contentReport->setCreatedAt(new \DateTime($data['createdAt']));
        if (isset($data['reviewedAt'])) $contentReport->setReviewedAt(new \DateTime($data['reviewedAt']));
        if (!isset($data['reporter'])) return $this->json(['error' => 'reporter is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_reporter = $this->playerRepository->find($data['reporter']);
        if (!$rel_reporter) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $contentReport->setReporter($rel_reporter);
        if (array_key_exists('reviewedBy', $data)) {
            $contentReport->setReviewedBy($data['reviewedBy'] !== null ? $this->playerRepository->find($data['reviewedBy']) : null);
        }
        if (array_key_exists('article', $data)) {
            $contentReport->setArticle($data['article'] !== null ? $this->articleRepository->find($data['article']) : null);
        }
        if (array_key_exists('articleComment', $data)) {
            $contentReport->setArticleComment($data['articleComment'] !== null ? $this->articleCommentRepository->find($data['articleComment']) : null);
        }

        $errors = $this->validator->validate($contentReport);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($contentReport, flush: true);
        return $this->json($contentReport, Response::HTTP_CREATED, context: ['groups' => ['contentReport:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(ContentReport $contentReport): JsonResponse
    {
        return $this->json($contentReport, context: ['groups' => ['contentReport:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, ContentReport $contentReport): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['targetType'])) $contentReport->setTargetType($data['targetType']);
        if (isset($data['reason'])) $contentReport->setReason($data['reason']);
        if (isset($data['description'])) $contentReport->setDescription($data['description']);
        if (isset($data['status'])) $contentReport->setStatus($data['status']);
        if (isset($data['createdAt'])) $contentReport->setCreatedAt(new \DateTime($data['createdAt']));
        if (isset($data['reviewedAt'])) $contentReport->setReviewedAt(new \DateTime($data['reviewedAt']));
        if (isset($data['reporter'])) {
            $rel_reporter = $this->playerRepository->find($data['reporter']);
            if (!$rel_reporter) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $contentReport->setReporter($rel_reporter);
        }
        if (array_key_exists('reviewedBy', $data)) {
            $contentReport->setReviewedBy($data['reviewedBy'] !== null ? $this->playerRepository->find($data['reviewedBy']) : null);
        }
        if (array_key_exists('article', $data)) {
            $contentReport->setArticle($data['article'] !== null ? $this->articleRepository->find($data['article']) : null);
        }
        if (array_key_exists('articleComment', $data)) {
            $contentReport->setArticleComment($data['articleComment'] !== null ? $this->articleCommentRepository->find($data['articleComment']) : null);
        }

        $errors = $this->validator->validate($contentReport);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($contentReport, flush: true);
        return $this->json($contentReport, context: ['groups' => ['contentReport:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(ContentReport $contentReport): JsonResponse
    {
        $this->repository->remove($contentReport, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
