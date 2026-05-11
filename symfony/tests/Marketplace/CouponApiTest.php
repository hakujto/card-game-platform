<?php

namespace App\Tests\Marketplace;

use App\Entity\Marketplace\Coupon;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;

class CouponApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $entity = new Coupon();
        $entity->setCode('test');
        $entity->setDiscountValue('0.00');
        $entity->setValidFrom(new \DateTime('2024-01-01'));
        $entity->setValidUntil(new \DateTime('2024-01-01'));
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/coupons');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/coupons', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'code' => 'test',
            'discountValue' => '0.00',
            'minOrderValue' => '0.00',
            'usesCount' => 1,
            'validFrom' => '2024-01-01T00:00:00+00:00',
            'validUntil' => '2024-01-01T00:00:00+00:00',
            'isActive' => true,
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/coupons/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/coupons/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['code' => 'test'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/coupons/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }
}
