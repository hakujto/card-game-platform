<?php

namespace App\Controller\Api\Content;

use App\Entity\Content\ArticleTag;
use App\Repository\Content\ArticleTagRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;


#[Route('/api/article_tags', name: 'articleTag_')]
class ArticleTagController extends AbstractController
{
    public function __construct(
        private ArticleTagRepository $repository,
        private ValidatorInterface $validator,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['articleTag:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $articleTag = new ArticleTag();
        if (isset($data['name'])) $articleTag->setName($data['name']);
        if (isset($data['slug'])) $articleTag->setSlug($data['slug']);


        $errors = $this->validator->validate($articleTag);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($articleTag, flush: true);
        return $this->json($articleTag, Response::HTTP_CREATED, context: ['groups' => ['articleTag:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(ArticleTag $articleTag): JsonResponse
    {
        return $this->json($articleTag, context: ['groups' => ['articleTag:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, ArticleTag $articleTag): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['name'])) $articleTag->setName($data['name']);
        if (isset($data['slug'])) $articleTag->setSlug($data['slug']);


        $errors = $this->validator->validate($articleTag);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($articleTag, flush: true);
        return $this->json($articleTag, context: ['groups' => ['articleTag:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(ArticleTag $articleTag): JsonResponse
    {
        $this->repository->remove($articleTag, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

}
