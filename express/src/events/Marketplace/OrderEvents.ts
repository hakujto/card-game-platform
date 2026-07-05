// Order domain events

export interface OrderPaid {
  readonly type: 'OrderPaid';
  readonly orderId: number;
  readonly playerId: number;
  readonly total: number;
  readonly paymentMethod: string;
  readonly paidAt: string;
}

export interface OrderShipped {
  readonly type: 'OrderShipped';
  readonly orderId: number;
  readonly trackingNumber: string;
  readonly shippedAt: string;
}

export interface OrderRefunded {
  readonly type: 'OrderRefunded';
  readonly orderId: number;
  readonly refundedAt: string;
}
