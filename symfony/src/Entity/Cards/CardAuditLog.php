<?php

namespace App\Entity\Cards;

use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity]
#[ORM\Table(name: 'cards_audit_log')]
class CardAuditLog
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    private ?int $id = null;

    #[ORM\Column]
    private int $recordId;

    #[ORM\Column(length: 100)]
    private string $field;

    #[ORM\Column(type: 'text', nullable: true)]
    private ?string $oldValue = null;

    #[ORM\Column(type: 'text', nullable: true)]
    private ?string $newValue = null;

    #[ORM\Column]
    private \DateTimeImmutable $changedAt;

    public function __construct() { $this->changedAt = new \DateTimeImmutable(); }

    // TODO: add getters/setters or use Symfony maker
}
