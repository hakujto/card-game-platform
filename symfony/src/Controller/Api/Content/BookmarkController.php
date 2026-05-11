<?php

namespace App\Controller\Api\Content;

use App\Entity\Content\Bookmark;
use App\Repository\Content\BookmarkRepository;
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
use App\Entity\Cards\Deck;
use App\Repository\Cards\DeckRepository;

#[Route('/api/bookmarks', name: 'bookmark_')]
class BookmarkController extends AbstractController
{
    public function __construct(
        private BookmarkRepository $repository,
        private ValidatorInterface $validator,
        private PlayerRepository $playerRepository,
        private ArticleRepository $articleRepository,
        private DeckRepository $deckRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['bookmark:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $bookmark = new Bookmark();
        if (isset($data['targetType'])) $bookmark->setTargetType($data['targetType']);
        if (isset($data['createdAt'])) $bookmark->setCreatedAt(new \DateTime($data['createdAt']));
        if (!isset($data['player'])) return $this->json(['error' => 'player is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_player = $this->playerRepository->find($data['player']);
        if (!$rel_player) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $bookmark->setPlayer($rel_player);
        if (array_key_exists('article', $data)) {
            $bookmark->setArticle($data['article'] !== null ? $this->articleRepository->find($data['article']) : null);
        }
        if (array_key_exists('deck', $data)) {
            $bookmark->setDeck($data['deck'] !== null ? $this->deckRepository->find($data['deck']) : null);
        }

        $errors = $this->validator->validate($bookmark);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($bookmark, flush: true);
        return $this->json($bookmark, Response::HTTP_CREATED, context: ['groups' => ['bookmark:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(Bookmark $bookmark): JsonResponse
    {
        return $this->json($bookmark, context: ['groups' => ['bookmark:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, Bookmark $bookmark): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['targetType'])) $bookmark->setTargetType($data['targetType']);
        if (isset($data['createdAt'])) $bookmark->setCreatedAt(new \DateTime($data['createdAt']));
        if (isset($data['player'])) {
            $rel_player = $this->playerRepository->find($data['player']);
            if (!$rel_player) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $bookmark->setPlayer($rel_player);
        }
        if (array_key_exists('article', $data)) {
            $bookmark->setArticle($data['article'] !== null ? $this->articleRepository->find($data['article']) : null);
        }
        if (array_key_exists('deck', $data)) {
            $bookmark->setDeck($data['deck'] !== null ? $this->deckRepository->find($data['deck']) : null);
        }

        $errors = $this->validator->validate($bookmark);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($bookmark, flush: true);
        return $this->json($bookmark, context: ['groups' => ['bookmark:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(Bookmark $bookmark): JsonResponse
    {
        $this->repository->remove($bookmark, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
