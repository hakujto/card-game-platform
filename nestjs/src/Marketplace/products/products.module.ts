import { Module } from '@nestjs/common';
import { ProductController } from './products.controller';
import { ProductService } from './product.service';

@Module({
  controllers: [ProductController],
  providers: [ProductService],
})
export class ProductModule {}
