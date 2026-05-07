<?php

namespace App\Tests\Marketplace;

use App\Entity\Marketplace\Coupon;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;

class CouponApiTest extends WebTestCase
{
    private EntityManagerInterface $em;
    private int $entityId;

    protected function setUp(): void
    {
        $client = static::createClient();
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
        $client = static::createClient();
        $client->request('GET', '/api/coupons');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $client = static::createClient();
        $client->request('POST', '/api/coupons', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'code' => 'test',
            'discount_value' => '0.00',
            'min_order_value' => '0.00',
            'uses_count' => 1,
            'valid_from' => new \DateTime('2024-01-01'),
            'valid_until' => new \DateTime('2024-01-01'),
            'is_active' => true,
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $client = static::createClient();
        $client->request('GET', '/api/coupons/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $client = static::createClient();
        $client->request('PATCH', '/api/coupons/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['code' => 'test'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $client = static::createClient();
        $client->request('DELETE', '/api/coupons/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }
}
