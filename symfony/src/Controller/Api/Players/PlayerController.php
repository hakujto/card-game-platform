<?php

namespace App\Controller\Api\Players;

use App\Entity\Players\Player;
use App\Repository\Players\PlayerRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\User;
use App\Repository\UserRepository;
use App\Entity\Players\PlayerSeasonStats;
use App\Repository\Players\PlayerSeasonStatsRepository;

#[Route('/api/players', name: 'player_')]
class PlayerController extends AbstractController
{
    public function __construct(
        private PlayerRepository $repository,
        private ValidatorInterface $validator,
        private UserRepository $userRepository,
        private PlayerSeasonStatsRepository $playerSeasonStatsRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['player:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $player = new Player();
        if (isset($data['displayName'])) $player->setDisplayName($data['displayName']);
        if (isset($data['rank'])) $player->setRank($data['rank']);
        if (isset($data['rating'])) $player->setRating($data['rating']);
        if (isset($data['peakRating'])) $player->setPeakRating($data['peakRating']);
        if (isset($data['bio'])) $player->setBio($data['bio']);
        if (isset($data['countryCode'])) $player->setCountryCode($data['countryCode']);
        if (isset($data['avatarUrl'])) $player->setAvatarUrl($data['avatarUrl']);
        if (isset($data['preferredFormat'])) $player->setPreferredFormat($data['preferredFormat']);
        if (isset($data['isVerified'])) $player->setIsVerified($data['isVerified']);
        if (isset($data['createdAt'])) $player->setCreatedAt(new \DateTime($data['createdAt']));
        if (isset($data['lastActiveAt'])) $player->setLastActiveAt(new \DateTime($data['lastActiveAt']));
        if (array_key_exists('user', $data)) {
            $player->setUser($data['user'] !== null ? $this->userRepository->find($data['user']) : null);
        }
        if (!isset($data['seasonStats'])) return $this->json(['error' => 'seasonStats is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_seasonStats = $this->playerSeasonStatsRepository->find($data['seasonStats']);
        if (!$rel_seasonStats) return $this->json(['error' => 'PlayerSeasonStats not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $player->setSeasonStats($rel_seasonStats);

        $errors = $this->validator->validate($player);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($player, flush: true);
        return $this->json($player, Response::HTTP_CREATED, context: ['groups' => ['player:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(Player $player): JsonResponse
    {
        return $this->json($player, context: ['groups' => ['player:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, Player $player): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['displayName'])) $player->setDisplayName($data['displayName']);
        if (isset($data['rank'])) $player->setRank($data['rank']);
        if (isset($data['rating'])) $player->setRating($data['rating']);
        if (isset($data['peakRating'])) $player->setPeakRating($data['peakRating']);
        if (isset($data['bio'])) $player->setBio($data['bio']);
        if (isset($data['countryCode'])) $player->setCountryCode($data['countryCode']);
        if (isset($data['avatarUrl'])) $player->setAvatarUrl($data['avatarUrl']);
        if (isset($data['preferredFormat'])) $player->setPreferredFormat($data['preferredFormat']);
        if (isset($data['isVerified'])) $player->setIsVerified($data['isVerified']);
        if (isset($data['createdAt'])) $player->setCreatedAt(new \DateTime($data['createdAt']));
        if (isset($data['lastActiveAt'])) $player->setLastActiveAt(new \DateTime($data['lastActiveAt']));
        if (array_key_exists('user', $data)) {
            $player->setUser($data['user'] !== null ? $this->userRepository->find($data['user']) : null);
        }
        if (isset($data['seasonStats'])) {
            $rel_seasonStats = $this->playerSeasonStatsRepository->find($data['seasonStats']);
            if (!$rel_seasonStats) return $this->json(['error' => 'PlayerSeasonStats not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $player->setSeasonStats($rel_seasonStats);
        }

        $errors = $this->validator->validate($player);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($player, flush: true);
        return $this->json($player, context: ['groups' => ['player:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(Player $player): JsonResponse
    {
        $this->repository->remove($player, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
