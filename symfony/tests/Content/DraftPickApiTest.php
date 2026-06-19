<?php

namespace App\Tests\Content;

use App\Entity\Content\DraftPick;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Players\Player;
use App\Entity\Content\DraftParticipant;
use App\Entity\Cards\CardSet;
use App\Entity\Cards\Card;

class DraftPickApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Player $auxPlayer;
    private DraftParticipant $depParticipant;
    private CardSet $auxCardSet;
    private Card $depCard;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->auxPlayer = new Player();
        $this->auxPlayer->setDisplayName('test2');
        $this->auxPlayer->setCreatedAt(new \DateTime('2024-01-01'));
        $this->em->persist($this->auxPlayer);
        $this->depParticipant = new DraftParticipant();
        $this->depParticipant->setSeatNumber(1);
        $this->depParticipant->setJoinedAt(new \DateTime('2024-01-01'));
        $this->depParticipant->setPlayer($this->auxPlayer);
        $this->em->persist($this->depParticipant);
        $this->auxCardSet = new CardSet();
        $this->auxCardSet->setName('test');
        $this->auxCardSet->setCode('test4');
        $this->auxCardSet->setReleaseDate(new \DateTime('2024-01-01'));
        $this->auxCardSet->setTotalCards(1);
        $this->em->persist($this->auxCardSet);
        $this->depCard = new Card();
        $this->depCard->setName('test');
        $this->depCard->setManaColors('test');
        $this->depCard->setDescription('test');
        $this->depCard->setLegalFormats('test');
        $this->depCard->setSet($this->auxCardSet);
        $this->em->persist($this->depCard);

        $entity = new DraftPick();
        $entity->setPickNumber(1);
        $entity->setPackNumber(1);
        $entity->setPickedAt(new \DateTime('2024-01-01'));
        $entity->setParticipant($this->depParticipant);
        $entity->setCard($this->depCard);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/draft_picks');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/draft_picks/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

}
