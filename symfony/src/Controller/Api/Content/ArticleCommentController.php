<?php

namespace App\Controller\Api\Content;

use App\Entity\Content\ArticleComment;
use App\Repository\Content\ArticleCommentRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Content\Article;
use App\Repository\Content\ArticleRepository;
use App\Entity\Players\Player;
use App\Repository\Players\PlayerRepository;

#[Route('/api/article_comments', name: 'articleComment_')]
class ArticleCommentController extends AbstractController
{
    public function __construct(
        private ArticleCommentRepository $repository,
        private ValidatorInterface $validator,
        private ArticleRepository $articleRepository,
        private PlayerRepository $playerRepository,
        private ArticleCommentRepository $articleCommentRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['articleComment:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $articleComment = new ArticleComment();
        if (isset($data['body'])) $articleComment->setBody($data['body']);
        if (isset($data['isHidden'])) $articleComment->setIsHidden($data['isHidden']);
        if (isset($data['createdAt'])) $articleComment->setCreatedAt(new \DateTime($data['createdAt']));
        if (array_key_exists('article', $data)) {
            $articleComment->setArticle($data['article'] !== null ? $this->articleRepository->find($data['article']) : null);
        }
        if (!isset($data['author'])) return $this->json(['error' => 'author is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_author = $this->playerRepository->find($data['author']);
        if (!$rel_author) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $articleComment->setAuthor($rel_author);
        if (array_key_exists('parentComment', $data)) {
            $articleComment->setParentComment($data['parentComment'] !== null ? $this->articleCommentRepository->find($data['parentComment']) : null);
        }

        $errors = $this->validator->validate($articleComment);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($articleComment, flush: true);
        return $this->json($articleComment, Response::HTTP_CREATED, context: ['groups' => ['articleComment:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(ArticleComment $articleComment): JsonResponse
    {
        return $this->json($articleComment, context: ['groups' => ['articleComment:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, ArticleComment $articleComment): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['body'])) $articleComment->setBody($data['body']);
        if (isset($data['isHidden'])) $articleComment->setIsHidden($data['isHidden']);
        if (isset($data['createdAt'])) $articleComment->setCreatedAt(new \DateTime($data['createdAt']));
        if (array_key_exists('article', $data)) {
            $articleComment->setArticle($data['article'] !== null ? $this->articleRepository->find($data['article']) : null);
        }
        if (isset($data['author'])) {
            $rel_author = $this->playerRepository->find($data['author']);
            if (!$rel_author) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $articleComment->setAuthor($rel_author);
        }
        if (array_key_exists('parentComment', $data)) {
            $articleComment->setParentComment($data['parentComment'] !== null ? $this->articleCommentRepository->find($data['parentComment']) : null);
        }

        $errors = $this->validator->validate($articleComment);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($articleComment, flush: true);
        return $this->json($articleComment, context: ['groups' => ['articleComment:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(ArticleComment $articleComment): JsonResponse
    {
        $this->repository->remove($articleComment, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/hide', name: 'hide', methods: ['POST'])]
    public function hide(ArticleComment $articleComment): JsonResponse
    {
        $articleComment->hide();
        $this->repository->save($articleComment, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/unhide', name: 'unhide', methods: ['POST'])]
    public function unhide(ArticleComment $articleComment): JsonResponse
    {
        $articleComment->unhide();
        $this->repository->save($articleComment, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
