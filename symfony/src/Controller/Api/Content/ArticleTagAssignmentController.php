<?php

namespace App\Controller\Api\Content;

use App\Entity\Content\ArticleTagAssignment;
use App\Repository\Content\ArticleTagAssignmentRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Content\Article;
use App\Repository\Content\ArticleRepository;
use App\Entity\Content\ArticleTag;
use App\Repository\Content\ArticleTagRepository;

#[Route('/api/article_tag_assignments', name: 'articleTagAssignment_')]
class ArticleTagAssignmentController extends AbstractController
{
    public function __construct(
        private ArticleTagAssignmentRepository $repository,
        private ValidatorInterface $validator,
        private ArticleRepository $articleRepository,
        private ArticleTagRepository $articleTagRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['articleTagAssignment:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $articleTagAssignment = new ArticleTagAssignment();

        if (!isset($data['article'])) return $this->json(['error' => 'article is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_article = $this->articleRepository->find($data['article']);
        if (!$rel_article) return $this->json(['error' => 'Article not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $articleTagAssignment->setArticle($rel_article);
        if (!isset($data['tag'])) return $this->json(['error' => 'tag is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_tag = $this->articleTagRepository->find($data['tag']);
        if (!$rel_tag) return $this->json(['error' => 'ArticleTag not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $articleTagAssignment->setTag($rel_tag);

        $errors = $this->validator->validate($articleTagAssignment);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($articleTagAssignment, flush: true);
        return $this->json($articleTagAssignment, Response::HTTP_CREATED, context: ['groups' => ['articleTagAssignment:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(ArticleTagAssignment $articleTagAssignment): JsonResponse
    {
        return $this->json($articleTagAssignment, context: ['groups' => ['articleTagAssignment:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, ArticleTagAssignment $articleTagAssignment): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];

        if (isset($data['article'])) {
            $rel_article = $this->articleRepository->find($data['article']);
            if (!$rel_article) return $this->json(['error' => 'Article not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $articleTagAssignment->setArticle($rel_article);
        }
        if (isset($data['tag'])) {
            $rel_tag = $this->articleTagRepository->find($data['tag']);
            if (!$rel_tag) return $this->json(['error' => 'ArticleTag not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $articleTagAssignment->setTag($rel_tag);
        }

        $errors = $this->validator->validate($articleTagAssignment);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($articleTagAssignment, flush: true);
        return $this->json($articleTagAssignment, context: ['groups' => ['articleTagAssignment:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(ArticleTagAssignment $articleTagAssignment): JsonResponse
    {
        $this->repository->remove($articleTagAssignment, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
