<?php

namespace App\Listeners\Wallet;

class on_order_paid
{
    // Listens to: OrderPaid
    // Action:     deduct_credits_if_platform_payment
    public function handle(object $event): void
    {
        // TODO: implement deduct_credits_if_platform_payment
        throw new \RuntimeException('Not implemented');
    }
}

class on_tournament_completed
{
    // Listens to: TournamentCompleted
    // Action:     distribute_prize_credits
    public function handle(object $event): void
    {
        // TODO: implement distribute_prize_credits
        throw new \RuntimeException('Not implemented');
    }
}
