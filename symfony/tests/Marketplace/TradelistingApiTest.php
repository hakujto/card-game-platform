<?php

namespace App\Tests\Marketplace;

use App\Entity\Marketplace\TradeListing;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Players\Player;
use App\Entity\Cards\CardSet;
use App\Entity\Cards\Card;
use App\Entity\User;

class TradeListingApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Player $depSeller;
    private CardSet $auxCardSet;
    private Card $depCard;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->depSeller = new Player();
        $this->depSeller->setPublicId('00000000-0000-0000-0000-0000000000012');
        $this->depSeller->setDisplayName('test2');
        $this->depSeller->setCreatedAt(new \DateTime('2024-01-01'));
        $this->em->persist($this->depSeller);
        $this->auxCardSet = new CardSet();
        $this->auxCardSet->setName('test');
        $this->auxCardSet->setCode('tC');
        $this->auxCardSet->setReleaseDate(new \DateTime('2024-01-01'));
        $this->auxCardSet->setTotalCards(1);
        $this->em->persist($this->auxCardSet);
        $this->depCard = new Card();
        $this->depCard->setPublicId('00000000-0000-0000-0000-0000000000014');
        $this->depCard->setName('test');
        $this->depCard->setManaColors('test');
        $this->depCard->setDescription('test');
        $this->depCard->setLegalFormats('test');
        $this->depCard->setSet($this->auxCardSet);
        $this->em->persist($this->depCard);

        $entity = new TradeListing();
        $entity->setPublicId('00000000-0000-0000-0000-000000000001');
        $entity->setCreatedAt(new \DateTime('2024-01-01'));
        $entity->setSeller($this->depSeller);
        $entity->setCard($this->depCard);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/trade_listings');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testSearchReturns200(): void
    {
        $this->client->request('GET', '/api/trade_listings?q=test');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/trade_listings', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'publicId' => '00000000-0000-0000-0000-0000000000012',
            'createdAt' => '2024-01-01T00:00:00+00:00',
            'seller' => (int) $this->depSeller->getId(),
            'card' => (int) $this->depCard->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/trade_listings/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/trade_listings/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['publicId' => '00000000-0000-0000-0000-000000000001'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateFailsWhenFixedPriceRequiresAskingPriceViolated(): void
    {
        // Fixed price listing must have an asking price
        $this->client->request('POST', '/api/trade_listings', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['publicId' => '00000000-0000-0000-0000-000000000001', 'status' => 'ACTIVE', 'foil' => true, 'condition' => 'MINT', 'quantity' => 1, 'createdAt' => '2024-01-01T00:00:00+00:00', 'sellerId' => 1, 'cardId' => 1, 'listingType' => 'FIXEDPRICE', 'askingPrice' => null])
        );
        $this->assertResponseStatusCodeSame(422);
    }

    public function testCreateFailsWhenAuctionRequiresStartPriceAndEndTimeViolated(): void
    {
        // Auction listing must have a start price and end time
        $this->client->request('POST', '/api/trade_listings', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['publicId' => '00000000-0000-0000-0000-000000000001', 'status' => 'ACTIVE', 'foil' => true, 'condition' => 'MINT', 'quantity' => 1, 'createdAt' => '2024-01-01T00:00:00+00:00', 'sellerId' => 1, 'cardId' => 1, 'listingType' => 'AUCTION', 'auctionStartPrice' => null])
        );
        $this->assertResponseStatusCodeSame(422);
    }

    public function testCreateFailsWhenQuantityPositiveViolated(): void
    {
        // Listing quantity must be between 1 and 9999
        $this->client->request('POST', '/api/trade_listings', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['publicId' => '00000000-0000-0000-0000-000000000001', 'status' => 'ACTIVE', 'foil' => true, 'condition' => 'MINT', 'createdAt' => '2024-01-01T00:00:00+00:00', 'sellerId' => 1, 'cardId' => 1, 'listingType' => 'FIXEDPRICE', 'askingPrice' => '0.00', 'listingType' => 'AUCTION', 'auctionStartPrice' => '0.00', 'auctionEndTime' => '2024-01-01T00:00:00+00:00', 'quantity' => 10000])
        );
        $this->assertResponseStatusCodeSame(422);
    }
    public function testTransitionPendingToActiveSucceeds(): void
    {
        $user = new User();
        $user->setEmail('pendingToActive@example.com');
        $user->setPassword('test');
        $user->setRoles(['ROLE_SELLER']);
        $this->em->persist($user);
        $this->em->flush();
        $this->client->loginUser($user);

        $entity = $this->em->find(TradeListing::class, $this->entityId);
        $entity->setStatus('Pending');
        $entity->setQuantity(1); // @on: quantity != null
        $this->em->flush();

        $this->client->request('PATCH', '/api/trade_listings/' . $this->entityId . '/transitions/pending-to-active');
        $this->assertResponseIsSuccessful();
        $data = json_decode($this->client->getResponse()->getContent(), true);
        $this->assertEquals('Active', $data['status'] ?? null);
    }

    public function testTransitionPendingToActiveDeniedForWrongRole(): void
    {
        $user = new User();
        $user->setEmail('pendingToActive.wrong@example.com');
        $user->setPassword('test');
        $this->em->persist($user);
        $this->em->flush();
        $this->client->loginUser($user);

        $this->client->request('PATCH', '/api/trade_listings/' . $this->entityId . '/transitions/pending-to-active');
        $this->assertResponseStatusCodeSame(403);
    }

    public function testTransitionActiveToSoldSucceeds(): void
    {
        $entity = $this->em->find(TradeListing::class, $this->entityId);
        $entity->setStatus('Active');
        $this->em->flush();

        $this->client->request('PATCH', '/api/trade_listings/' . $this->entityId . '/transitions/active-to-sold');
        $this->assertResponseIsSuccessful();
        $data = json_decode($this->client->getResponse()->getContent(), true);
        $this->assertEquals('Sold', $data['status'] ?? null);
    }

    public function testTransitionActiveToExpiredSucceeds(): void
    {
        $entity = $this->em->find(TradeListing::class, $this->entityId);
        $entity->setStatus('Active');
        $this->em->flush();

        $this->client->request('PATCH', '/api/trade_listings/' . $this->entityId . '/transitions/active-to-expired');
        $this->assertResponseIsSuccessful();
        $data = json_decode($this->client->getResponse()->getContent(), true);
        $this->assertEquals('Expired', $data['status'] ?? null);
    }

    public function testTransitionActiveToCancelledSucceeds(): void
    {
        $user = new User();
        $user->setEmail('activeToCancelled@example.com');
        $user->setPassword('test');
        $user->setRoles(['ROLE_SELLER', 'ROLE_ADMIN']);
        $this->em->persist($user);
        $this->em->flush();
        $this->client->loginUser($user);

        $entity = $this->em->find(TradeListing::class, $this->entityId);
        $entity->setStatus('Active');
        $this->em->flush();

        $this->client->request('PATCH', '/api/trade_listings/' . $this->entityId . '/transitions/active-to-cancelled');
        $this->assertResponseIsSuccessful();
        $data = json_decode($this->client->getResponse()->getContent(), true);
        $this->assertEquals('Cancelled', $data['status'] ?? null);
    }

    public function testTransitionActiveToCancelledDeniedForWrongRole(): void
    {
        $user = new User();
        $user->setEmail('activeToCancelled.wrong@example.com');
        $user->setPassword('test');
        $this->em->persist($user);
        $this->em->flush();
        $this->client->loginUser($user);

        $this->client->request('PATCH', '/api/trade_listings/' . $this->entityId . '/transitions/active-to-cancelled');
        $this->assertResponseStatusCodeSame(403);
    }

    public function testTransitionSoldToActiveIsDenied(): void
    {
        $this->client->request('PATCH', '/api/trade_listings/' . $this->entityId . '/transitions/sold-to-active');
        $this->assertResponseStatusCodeSame(409);
    }

    public function testTransitionExpiredToActiveIsDenied(): void
    {
        $this->client->request('PATCH', '/api/trade_listings/' . $this->entityId . '/transitions/expired-to-active');
        $this->assertResponseStatusCodeSame(409);
    }
}
