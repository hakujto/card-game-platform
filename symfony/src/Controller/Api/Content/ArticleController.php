<?php

namespace App\Controller\Api\Content;

use App\Entity\Content\Article;
use App\Repository\Content\ArticleRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Players\Player;
use App\Repository\Players\PlayerRepository;
use App\Entity\Cards\Deck;
use App\Repository\Cards\DeckRepository;
use App\Entity\Content\ArticleComment;
use App\Repository\Content\ArticleCommentRepository;

#[Route('/api/articles', name: 'article_')]
class ArticleController extends AbstractController
{
    public function __construct(
        private ArticleRepository $repository,
        private ValidatorInterface $validator,
        private PlayerRepository $playerRepository,
        private DeckRepository $deckRepository,
        private ArticleCommentRepository $articleCommentRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['article:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $article = new Article();
        if (isset($data['title'])) $article->setTitle($data['title']);
        if (isset($data['slug'])) $article->setSlug($data['slug']);
        if (isset($data['body'])) $article->setBody($data['body']);
        if (isset($data['excerpt'])) $article->setExcerpt($data['excerpt']);
        if (isset($data['coverImageUrl'])) $article->setCoverImageUrl($data['coverImageUrl']);
        if (isset($data['status'])) $article->setStatus($data['status']);
        if (isset($data['articleType'])) $article->setArticleType($data['articleType']);
        if (isset($data['viewCount'])) $article->setViewCount($data['viewCount']);
        if (isset($data['publishedAt'])) $article->setPublishedAt(new \DateTime($data['publishedAt']));
        if (isset($data['createdAt'])) $article->setCreatedAt(new \DateTime($data['createdAt']));
        if (isset($data['updatedAt'])) $article->setUpdatedAt(new \DateTime($data['updatedAt']));
        if (!isset($data['author'])) return $this->json(['error' => 'author is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_author = $this->playerRepository->find($data['author']);
        if (!$rel_author) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $article->setAuthor($rel_author);
        if (array_key_exists('featuredDeck', $data)) {
            $article->setFeaturedDeck($data['featuredDeck'] !== null ? $this->deckRepository->find($data['featuredDeck']) : null);
        }
        if (!isset($data['comments'])) return $this->json(['error' => 'comments is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_comments = $this->articleCommentRepository->find($data['comments']);
        if (!$rel_comments) return $this->json(['error' => 'ArticleComment not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $article->setComments($rel_comments);

        $errors = $this->validator->validate($article);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($article, flush: true);
        return $this->json($article, Response::HTTP_CREATED, context: ['groups' => ['article:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(Article $article): JsonResponse
    {
        return $this->json($article, context: ['groups' => ['article:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, Article $article): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['title'])) $article->setTitle($data['title']);
        if (isset($data['slug'])) $article->setSlug($data['slug']);
        if (isset($data['body'])) $article->setBody($data['body']);
        if (isset($data['excerpt'])) $article->setExcerpt($data['excerpt']);
        if (isset($data['coverImageUrl'])) $article->setCoverImageUrl($data['coverImageUrl']);
        if (isset($data['status'])) $article->setStatus($data['status']);
        if (isset($data['articleType'])) $article->setArticleType($data['articleType']);
        if (isset($data['viewCount'])) $article->setViewCount($data['viewCount']);
        if (isset($data['publishedAt'])) $article->setPublishedAt(new \DateTime($data['publishedAt']));
        if (isset($data['createdAt'])) $article->setCreatedAt(new \DateTime($data['createdAt']));
        if (isset($data['updatedAt'])) $article->setUpdatedAt(new \DateTime($data['updatedAt']));
        if (isset($data['author'])) {
            $rel_author = $this->playerRepository->find($data['author']);
            if (!$rel_author) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $article->setAuthor($rel_author);
        }
        if (array_key_exists('featuredDeck', $data)) {
            $article->setFeaturedDeck($data['featuredDeck'] !== null ? $this->deckRepository->find($data['featuredDeck']) : null);
        }
        if (isset($data['comments'])) {
            $rel_comments = $this->articleCommentRepository->find($data['comments']);
            if (!$rel_comments) return $this->json(['error' => 'ArticleComment not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $article->setComments($rel_comments);
        }

        $errors = $this->validator->validate($article);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($article, flush: true);
        return $this->json($article, context: ['groups' => ['article:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(Article $article): JsonResponse
    {
        $this->repository->remove($article, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
