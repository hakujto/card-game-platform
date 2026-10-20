// TradeTransaction domain events

export interface TransactionCompleted {
  readonly type: 'TransactionCompleted';
  readonly transactionId: number;
  readonly buyerId: number;
  readonly sellerId: number;
  readonly finalPrice: number;
  readonly completedAt: string;
}
