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
use App\Service\Content\ArticleService;
use App\Entity\Players\Player;
use App\Repository\Players\PlayerRepository;
use App\Entity\Cards\Deck;
use App\Repository\Cards\DeckRepository;

#[Route('/api/articles', name: 'article_')]
class ArticleController extends AbstractController
{
    public function __construct(
        private ArticleRepository $repository,
        private ValidatorInterface $validator,
        private ArticleService $service,
        private PlayerRepository $playerRepository,
        private DeckRepository $deckRepository,
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
        if (isset($data['language'])) $article->setLanguage($data['language']);
        if (isset($data['viewCount'])) $article->setViewCount($data['viewCount']);
        if (isset($data['likesCount'])) $article->setLikesCount($data['likesCount']);
        if (isset($data['isFeatured'])) $article->setIsFeatured($data['isFeatured']);
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

        $errors = $this->validator->validate($article);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        try {
            $article->validateImplies();
        } catch (\DomainException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_UNPROCESSABLE_ENTITY);
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
        if (isset($data['language'])) $article->setLanguage($data['language']);
        if (isset($data['viewCount'])) $article->setViewCount($data['viewCount']);
        if (isset($data['likesCount'])) $article->setLikesCount($data['likesCount']);
        if (isset($data['isFeatured'])) $article->setIsFeatured($data['isFeatured']);
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

        $errors = $this->validator->validate($article);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        try {
            $article->validateImplies();
        } catch (\DomainException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_UNPROCESSABLE_ENTITY);
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

    #[Route('/{id}/publish', name: 'publish', methods: ['POST'])]
    public function publish(Article $article): JsonResponse
    {
        $article->publish();
        $this->repository->save($article, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/archive', name: 'archive', methods: ['POST'])]
    public function archive(Article $article): JsonResponse
    {
        $article->archive();
        $this->repository->save($article, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/view', name: 'incrementView', methods: ['POST'])]
    public function incrementView(Article $article): JsonResponse
    {
        $article->incrementView();
        $this->repository->save($article, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/like', name: 'like', methods: ['POST'])]
    public function like(Article $article): JsonResponse
    {
        $article->like();
        $this->repository->save($article, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/like', name: 'unlike', methods: ['DELETE'])]
    public function unlike(Article $article): JsonResponse
    {
        $article->unlike();
        $this->repository->save($article, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/reading-time', name: 'readingTimeMinutes', methods: ['GET'])]
    public function readingTimeMinutes(Article $article): JsonResponse
    {
        $result = $article->readingTimeMinutes();
        $this->repository->save($article, flush: true);
        return $this->json($result);
    }
    #[Route('/{id}/transitions/draft-to-published', name: 'article_transitionDraftToPublished', methods: ['PATCH'])]
    public function transitionDraftToPublished(Article $article): JsonResponse
    {
        try {
            $result = $this->service->transitionDraftToPublished($article->getId());
            return $this->json($result);
        } catch (\Symfony\Component\HttpKernel\Exception\ConflictHttpException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_CONFLICT);
        } catch (\Symfony\Component\HttpKernel\Exception\UnprocessableEntityHttpException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_UNPROCESSABLE_ENTITY);
        }
    }

    #[Route('/{id}/transitions/published-to-archived', name: 'article_transitionPublishedToArchived', methods: ['PATCH'])]
    public function transitionPublishedToArchived(Article $article): JsonResponse
    {
        try {
            $result = $this->service->transitionPublishedToArchived($article->getId());
            return $this->json($result);
        } catch (\Symfony\Component\HttpKernel\Exception\ConflictHttpException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_CONFLICT);
        } catch (\Symfony\Component\HttpKernel\Exception\UnprocessableEntityHttpException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_UNPROCESSABLE_ENTITY);
        }
    }

    #[Route('/{id}/transitions/archived-to-draft', name: 'article_transitionArchivedToDraft', methods: ['PATCH'])]
    public function transitionArchivedToDraft(Article $article): JsonResponse
    {
        try {
            $result = $this->service->transitionArchivedToDraft($article->getId());
            return $this->json($result);
        } catch (\Symfony\Component\HttpKernel\Exception\ConflictHttpException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_CONFLICT);
        } catch (\Symfony\Component\HttpKernel\Exception\UnprocessableEntityHttpException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_UNPROCESSABLE_ENTITY);
        }
    }

    #[Route('/{id}/transitions/published-to-draft', name: 'article_transitionPublishedToDraft', methods: ['PATCH'])]
    public function transitionPublishedToDraft(Article $article): JsonResponse
    {
        return $this->json(['error' => 'Transition Published -> Draft is not allowed'], Response::HTTP_CONFLICT);
    }
}
