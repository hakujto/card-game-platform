import { Module } from '@nestjs/common';
import { ArticleController } from './articles.controller';
import { ArticleService } from './article.service';

@Module({
  controllers: [ArticleController],
  providers: [ArticleService],
})
export class ArticleModule {}
