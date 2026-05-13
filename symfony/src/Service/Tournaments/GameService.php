<?php

namespace App\Service\Tournaments;

use App\Entity\Tournaments\Game;
use App\Repository\Tournaments\GameRepository;

class GameService
{
    public function __construct(
        private GameRepository $repository,
    ) {}

    public function create(array $data): Game
    {
        throw new \LogicException('Not implemented');
    }

    public function update(Game $entity, array $data): Game
    {
        throw new \LogicException('Not implemented');
    }

    public function recordWinner(int $id, $winnerSide): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Game not found: ' . $id);
        $entity->recordWinner($winnerSide);
        $this->repository->save($entity, flush: true);
    }
}
