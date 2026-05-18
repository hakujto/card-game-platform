<?php

namespace App\Controller\Api\Marketplace;

use App\Entity\Marketplace\Coupon;
use App\Repository\Marketplace\CouponRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;


#[Route('/api/coupons', name: 'coupon_')]
class CouponController extends AbstractController
{
    public function __construct(
        private CouponRepository $repository,
        private ValidatorInterface $validator,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['coupon:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $coupon = new Coupon();
        if (isset($data['code'])) $coupon->setCode($data['code']);
        if (isset($data['discountType'])) $coupon->setDiscountType($data['discountType']);
        if (isset($data['discountValue'])) $coupon->setDiscountValue($data['discountValue']);
        if (isset($data['minOrderValue'])) $coupon->setMinOrderValue($data['minOrderValue']);
        if (isset($data['maxUses'])) $coupon->setMaxUses($data['maxUses']);
        if (isset($data['usesCount'])) $coupon->setUsesCount($data['usesCount']);
        if (isset($data['validFrom'])) $coupon->setValidFrom(new \DateTime($data['validFrom']));
        if (isset($data['validUntil'])) $coupon->setValidUntil(new \DateTime($data['validUntil']));
        if (isset($data['isActive'])) $coupon->setIsActive($data['isActive']);


        $errors = $this->validator->validate($coupon);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        try {
            $coupon->validateImplies();
        } catch (\DomainException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($coupon, flush: true);
        return $this->json($coupon, Response::HTTP_CREATED, context: ['groups' => ['coupon:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(Coupon $coupon): JsonResponse
    {
        return $this->json($coupon, context: ['groups' => ['coupon:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, Coupon $coupon): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['code'])) $coupon->setCode($data['code']);
        if (isset($data['discountType'])) $coupon->setDiscountType($data['discountType']);
        if (isset($data['discountValue'])) $coupon->setDiscountValue($data['discountValue']);
        if (isset($data['minOrderValue'])) $coupon->setMinOrderValue($data['minOrderValue']);
        if (isset($data['maxUses'])) $coupon->setMaxUses($data['maxUses']);
        if (isset($data['usesCount'])) $coupon->setUsesCount($data['usesCount']);
        if (isset($data['validFrom'])) $coupon->setValidFrom(new \DateTime($data['validFrom']));
        if (isset($data['validUntil'])) $coupon->setValidUntil(new \DateTime($data['validUntil']));
        if (isset($data['isActive'])) $coupon->setIsActive($data['isActive']);


        $errors = $this->validator->validate($coupon);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        try {
            $coupon->validateImplies();
        } catch (\DomainException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($coupon, flush: true);
        return $this->json($coupon, context: ['groups' => ['coupon:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(Coupon $coupon): JsonResponse
    {
        $this->repository->remove($coupon, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/valid', name: 'isValid', methods: ['GET'])]
    public function isValid(Coupon $coupon): JsonResponse
    {
        $result = $coupon->isValid();
        $this->repository->save($coupon, flush: true);
        return $this->json($result);
    }

    #[Route('/{id}/applicable', name: 'isApplicableToOrder', methods: ['GET'])]
    public function isApplicableToOrder(Coupon $coupon): JsonResponse
    {
        $result = $coupon->isApplicableToOrder($orderTotal);
        $this->repository->save($coupon, flush: true);
        return $this->json($result);
    }

    #[Route('/{id}/redeem', name: 'redeem', methods: ['POST'])]
    public function redeem(Coupon $coupon): JsonResponse
    {
        $coupon->redeem();
        $this->repository->save($coupon, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/deactivate', name: 'deactivate', methods: ['POST'])]
    public function deactivate(Coupon $coupon): JsonResponse
    {
        $coupon->deactivate();
        $this->repository->save($coupon, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
