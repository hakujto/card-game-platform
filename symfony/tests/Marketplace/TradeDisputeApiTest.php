<?php

namespace App\Tests\Marketplace;

use App\Entity\Marketplace\TradeDispute;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Players\Player;
use App\Entity\Cards\CardSet;
use App\Entity\Cards\Card;
use App\Entity\Marketplace\TradeListing;
use App\Entity\Marketplace\TradeTransaction;
use App\Entity\User;

class TradeDisputeApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Player $auxPlayer;
    private CardSet $auxCardSet;
    private Card $auxCard;
    private TradeListing $auxTradeListing;
    private TradeTransaction $depTransaction;
    private Player $depOpenedBy;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->auxPlayer = new Player();
        $this->auxPlayer->setPublicId('00000000-0000-0000-0000-0000000000012');
        $this->auxPlayer->setDisplayName('test2');
        $this->auxPlayer->setCreatedAt(new \DateTime('2024-01-01'));
        $this->em->persist($this->auxPlayer);
        $this->auxCardSet = new CardSet();
        $this->auxCardSet->setName('test');
        $this->auxCardSet->setCode('tC');
        $this->auxCardSet->setReleaseDate(new \DateTime('2024-01-01'));
        $this->auxCardSet->setTotalCards(1);
        $this->em->persist($this->auxCardSet);
        $this->auxCard = new Card();
        $this->auxCard->setPublicId('00000000-0000-0000-0000-0000000000014');
        $this->auxCard->setName('test');
        $this->auxCard->setManaColors('test');
        $this->auxCard->setDescription('test');
        $this->auxCard->setLegalFormats('test');
        $this->auxCard->setSet($this->auxCardSet);
        $this->em->persist($this->auxCard);
        $this->auxTradeListing = new TradeListing();
        $this->auxTradeListing->setPublicId('00000000-0000-0000-0000-0000000000015');
        $this->auxTradeListing->setCreatedAt(new \DateTime('2024-01-01'));
        $this->auxTradeListing->setSeller($this->auxPlayer);
        $this->auxTradeListing->setCard($this->auxCard);
        $this->em->persist($this->auxTradeListing);
        $this->depTransaction = new TradeTransaction();
        $this->depTransaction->setFinalPrice('0.00');
        $this->depTransaction->setPlatformFee('0.00');
        $this->depTransaction->setListing($this->auxTradeListing);
        $this->depTransaction->setBuyer($this->auxPlayer);
        $this->depTransaction->setSeller($this->auxPlayer);
        $this->em->persist($this->depTransaction);
        $this->depOpenedBy = new Player();
        $this->depOpenedBy->setPublicId('00000000-0000-0000-0000-0000000000017');
        $this->depOpenedBy->setDisplayName('test7');
        $this->depOpenedBy->setCreatedAt(new \DateTime('2024-01-01'));
        $this->em->persist($this->depOpenedBy);

        $entity = new TradeDispute();
        $entity->setReason('test');
        $entity->setDescription('test');
        $entity->setOpenedAt(new \DateTime('2024-01-01'));
        $entity->setTransaction($this->depTransaction);
        $entity->setOpenedBy($this->depOpenedBy);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/trade_disputes');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $freshSubListing = new TradeListing();
        $freshSubListing->setPublicId('00000000-0000-0000-0000-0000000000012');
        $freshSubListing->setCreatedAt(new \DateTime('2024-01-01'));
        $freshSubListing->setSeller($this->auxPlayer);
        $freshSubListing->setCard($this->auxCard);
        $this->em->persist($freshSubListing);
        $freshTransaction = new TradeTransaction();
        $freshTransaction->setFinalPrice('0.01');
        $freshTransaction->setPlatformFee('NaN');
        $freshTransaction->setListing($freshSubListing);
        $freshTransaction->setBuyer($this->auxPlayer);
        $freshTransaction->setSeller($this->auxPlayer);
        $this->em->persist($freshTransaction);
        $this->em->flush();
        $this->client->request('POST', '/api/trade_disputes', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'description' => 'test',
            'openedAt' => '2024-01-01T00:00:00+00:00',
            'transaction' => (int) $freshTransaction->getId(),
            'openedBy' => (int) $this->depOpenedBy->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/trade_disputes/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateFailsWhenResolvedAtRequiresTerminalStatusViolated(): void
    {
        // resolved_at_requires_terminal_status
        $this->client->request('POST', '/api/trade_disputes', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['status' => 'OPEN', 'reason' => 'ITEMNOTRECEIVED', 'description' => 'test', 'openedAt' => '2024-01-01T00:00:00+00:00', 'transactionId' => 1, 'openedById' => 1, 'resolvedAt' => '2024-01-01T00:00:00+00:00'])
        );
        $this->assertResponseStatusCodeSame(422);
    }
    public function testTransitionOpenToUnderReviewSucceeds(): void
    {
        $user = new User();
        $user->setEmail('openToUnderReview@example.com');
        $user->setPassword('test');
        $user->setRoles(['ROLE_ADMIN', 'ROLE_MODERATOR']);
        $this->em->persist($user);
        $this->em->flush();
        $this->client->loginUser($user);

        $entity = $this->em->find(TradeDispute::class, $this->entityId);
        $entity->setStatus('Open');
        $this->em->flush();

        $this->client->request('PATCH', '/api/trade_disputes/' . $this->entityId . '/transitions/open-to-underreview');
        $this->assertResponseIsSuccessful();
        $data = json_decode($this->client->getResponse()->getContent(), true);
        $this->assertEquals('UnderReview', $data['status'] ?? null);
    }

    public function testTransitionOpenToUnderReviewDeniedForWrongRole(): void
    {
        $user = new User();
        $user->setEmail('openToUnderReview.wrong@example.com');
        $user->setPassword('test');
        $this->em->persist($user);
        $this->em->flush();
        $this->client->loginUser($user);

        $this->client->request('PATCH', '/api/trade_disputes/' . $this->entityId . '/transitions/open-to-underreview');
        $this->assertResponseStatusCodeSame(403);
    }

    public function testTransitionUnderReviewToResolvedSucceeds(): void
    {
        $user = new User();
        $user->setEmail('underReviewToResolved@example.com');
        $user->setPassword('test');
        $user->setRoles(['ROLE_ADMIN', 'ROLE_MODERATOR']);
        $this->em->persist($user);
        $this->em->flush();
        $this->client->loginUser($user);

        $entity = $this->em->find(TradeDispute::class, $this->entityId);
        $entity->setStatus('UnderReview');
        $entity->setResolution('test'); // @on: resolution != null
        $this->em->flush();

        $this->client->request('PATCH', '/api/trade_disputes/' . $this->entityId . '/transitions/underreview-to-resolved');
        $this->assertResponseIsSuccessful();
        $data = json_decode($this->client->getResponse()->getContent(), true);
        $this->assertEquals('Resolved', $data['status'] ?? null);
    }

    public function testTransitionUnderReviewToResolvedDeniedForWrongRole(): void
    {
        $user = new User();
        $user->setEmail('underReviewToResolved.wrong@example.com');
        $user->setPassword('test');
        $this->em->persist($user);
        $this->em->flush();
        $this->client->loginUser($user);

        $this->client->request('PATCH', '/api/trade_disputes/' . $this->entityId . '/transitions/underreview-to-resolved');
        $this->assertResponseStatusCodeSame(403);
    }

    public function testTransitionUnderReviewToResolvedFailsWhenResolutionMissing(): void
    {
        $user = new User();
        $user->setEmail('underReviewToResolved.missingResolution@example.com');
        $user->setPassword('test');
        $user->setRoles(['ROLE_ADMIN', 'ROLE_MODERATOR']);
        $this->em->persist($user);
        $this->em->flush();
        $this->client->loginUser($user);

        $entity = $this->em->find(TradeDispute::class, $this->entityId);
        $entity->setStatus('UnderReview');
        $this->em->flush();

        $this->client->request('PATCH', '/api/trade_disputes/' . $this->entityId . '/transitions/underreview-to-resolved');
        $this->assertResponseStatusCodeSame(422);
    }

    public function testTransitionUnderReviewToEscalatedSucceeds(): void
    {
        $user = new User();
        $user->setEmail('underReviewToEscalated@example.com');
        $user->setPassword('test');
        $user->setRoles(['ROLE_ADMIN']);
        $this->em->persist($user);
        $this->em->flush();
        $this->client->loginUser($user);

        $entity = $this->em->find(TradeDispute::class, $this->entityId);
        $entity->setStatus('UnderReview');
        $this->em->flush();

        $this->client->request('PATCH', '/api/trade_disputes/' . $this->entityId . '/transitions/underreview-to-escalated');
        $this->assertResponseIsSuccessful();
        $data = json_decode($this->client->getResponse()->getContent(), true);
        $this->assertEquals('Escalated', $data['status'] ?? null);
    }

    public function testTransitionUnderReviewToEscalatedDeniedForWrongRole(): void
    {
        $user = new User();
        $user->setEmail('underReviewToEscalated.wrong@example.com');
        $user->setPassword('test');
        $this->em->persist($user);
        $this->em->flush();
        $this->client->loginUser($user);

        $this->client->request('PATCH', '/api/trade_disputes/' . $this->entityId . '/transitions/underreview-to-escalated');
        $this->assertResponseStatusCodeSame(403);
    }

    public function testTransitionEscalatedToResolvedSucceeds(): void
    {
        $user = new User();
        $user->setEmail('escalatedToResolved@example.com');
        $user->setPassword('test');
        $user->setRoles(['ROLE_ADMIN']);
        $this->em->persist($user);
        $this->em->flush();
        $this->client->loginUser($user);

        $entity = $this->em->find(TradeDispute::class, $this->entityId);
        $entity->setStatus('Escalated');
        $entity->setResolution('test'); // @on: resolution != null
        $this->em->flush();

        $this->client->request('PATCH', '/api/trade_disputes/' . $this->entityId . '/transitions/escalated-to-resolved');
        $this->assertResponseIsSuccessful();
        $data = json_decode($this->client->getResponse()->getContent(), true);
        $this->assertEquals('Resolved', $data['status'] ?? null);
    }

    public function testTransitionEscalatedToResolvedDeniedForWrongRole(): void
    {
        $user = new User();
        $user->setEmail('escalatedToResolved.wrong@example.com');
        $user->setPassword('test');
        $this->em->persist($user);
        $this->em->flush();
        $this->client->loginUser($user);

        $this->client->request('PATCH', '/api/trade_disputes/' . $this->entityId . '/transitions/escalated-to-resolved');
        $this->assertResponseStatusCodeSame(403);
    }

    public function testTransitionEscalatedToResolvedFailsWhenResolutionMissing(): void
    {
        $user = new User();
        $user->setEmail('escalatedToResolved.missingResolution@example.com');
        $user->setPassword('test');
        $user->setRoles(['ROLE_ADMIN']);
        $this->em->persist($user);
        $this->em->flush();
        $this->client->loginUser($user);

        $entity = $this->em->find(TradeDispute::class, $this->entityId);
        $entity->setStatus('Escalated');
        $this->em->flush();

        $this->client->request('PATCH', '/api/trade_disputes/' . $this->entityId . '/transitions/escalated-to-resolved');
        $this->assertResponseStatusCodeSame(422);
    }

    public function testTransitionResolvedToOpenIsDenied(): void
    {
        $this->client->request('PATCH', '/api/trade_disputes/' . $this->entityId . '/transitions/resolved-to-open');
        $this->assertResponseStatusCodeSame(409);
    }
}
