<?php

namespace App\Controller\Api\Content;

use App\Entity\Content\Stream;
use App\Repository\Content\StreamRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Tournaments\Tournament;
use App\Repository\Tournaments\TournamentRepository;
use App\Entity\Players\Player;
use App\Repository\Players\PlayerRepository;

#[Route('/api/streams', name: 'stream_')]
class StreamController extends AbstractController
{
    public function __construct(
        private StreamRepository $repository,
        private ValidatorInterface $validator,
        private TournamentRepository $tournamentRepository,
        private PlayerRepository $playerRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['stream:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $stream = new Stream();
        if (isset($data['title'])) $stream->setTitle($data['title']);
        if (isset($data['streamUrl'])) $stream->setStreamUrl($data['streamUrl']);
        if (isset($data['platform'])) $stream->setPlatform($data['platform']);
        if (isset($data['status'])) $stream->setStatus($data['status']);
        if (isset($data['viewerCountPeak'])) $stream->setViewerCountPeak($data['viewerCountPeak']);
        if (isset($data['scheduledStart'])) $stream->setScheduledStart(new \DateTime($data['scheduledStart']));
        if (isset($data['actualStart'])) $stream->setActualStart(new \DateTime($data['actualStart']));
        if (isset($data['endedAt'])) $stream->setEndedAt(new \DateTime($data['endedAt']));
        if (isset($data['vodUrl'])) $stream->setVodUrl($data['vodUrl']);
        if (array_key_exists('tournament', $data)) {
            $stream->setTournament($data['tournament'] !== null ? $this->tournamentRepository->find($data['tournament']) : null);
        }
        if (!isset($data['streamer'])) return $this->json(['error' => 'streamer is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_streamer = $this->playerRepository->find($data['streamer']);
        if (!$rel_streamer) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $stream->setStreamer($rel_streamer);

        $errors = $this->validator->validate($stream);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        try {
            $stream->validateImplies();
        } catch (\DomainException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($stream, flush: true);
        return $this->json($stream, Response::HTTP_CREATED, context: ['groups' => ['stream:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(Stream $stream): JsonResponse
    {
        return $this->json($stream, context: ['groups' => ['stream:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, Stream $stream): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['title'])) $stream->setTitle($data['title']);
        if (isset($data['streamUrl'])) $stream->setStreamUrl($data['streamUrl']);
        if (isset($data['platform'])) $stream->setPlatform($data['platform']);
        if (isset($data['status'])) $stream->setStatus($data['status']);
        if (isset($data['viewerCountPeak'])) $stream->setViewerCountPeak($data['viewerCountPeak']);
        if (isset($data['scheduledStart'])) $stream->setScheduledStart(new \DateTime($data['scheduledStart']));
        if (isset($data['actualStart'])) $stream->setActualStart(new \DateTime($data['actualStart']));
        if (isset($data['endedAt'])) $stream->setEndedAt(new \DateTime($data['endedAt']));
        if (isset($data['vodUrl'])) $stream->setVodUrl($data['vodUrl']);
        if (array_key_exists('tournament', $data)) {
            $stream->setTournament($data['tournament'] !== null ? $this->tournamentRepository->find($data['tournament']) : null);
        }
        if (isset($data['streamer'])) {
            $rel_streamer = $this->playerRepository->find($data['streamer']);
            if (!$rel_streamer) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $stream->setStreamer($rel_streamer);
        }

        $errors = $this->validator->validate($stream);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        try {
            $stream->validateImplies();
        } catch (\DomainException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($stream, flush: true);
        return $this->json($stream, context: ['groups' => ['stream:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(Stream $stream): JsonResponse
    {
        $this->repository->remove($stream, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/live', name: 'goLive', methods: ['POST'])]
    public function goLive(Stream $stream): JsonResponse
    {
        $stream->goLive();
        $this->repository->save($stream, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/end', name: 'end', methods: ['POST'])]
    public function end(Stream $stream): JsonResponse
    {
        $stream->end();
        $this->repository->save($stream, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/viewers', name: 'updateViewerPeak', methods: ['PATCH'])]
    public function updateViewerPeak(Stream $stream, Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $stream->updateViewerPeak($data['count'] ?? null);
        $this->repository->save($stream, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
