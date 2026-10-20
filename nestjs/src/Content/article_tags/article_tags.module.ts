import { Module } from '@nestjs/common';
import { ArticleTagController } from './article_tags.controller';
import { ArticleTagService } from './article_tag.service';

@Module({
  controllers: [ArticleTagController],
  providers: [ArticleTagService],
})
export class ArticleTagModule {}
