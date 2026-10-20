import { Module } from '@nestjs/common';
import { ArticleTagAssignmentController } from './article_tag_assignments.controller';

@Module({
  controllers: [ArticleTagAssignmentController],
  providers: [],
})
export class ArticleTagAssignmentModule {}
