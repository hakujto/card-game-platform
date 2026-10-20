import { Module } from '@nestjs/common';
import { ArticleCommentController } from './article_comments.controller';
import { ArticleCommentService } from './article_comment.service';

@Module({
  controllers: [ArticleCommentController],
  providers: [ArticleCommentService],
})
export class ArticleCommentModule {}
