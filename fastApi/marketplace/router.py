from typing import Sequence

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.db import get_db
from .models import Product, Order, OrderItem, Coupon, Tradelisting, TradeBid, TradeTransaction, CardPriceHistory, TradeDispute
from .schemas import ProductCreate, ProductUpdate, ProductRead, OrderCreate, OrderUpdate, OrderRead, OrderItemCreate, OrderItemUpdate, OrderItemRead, CouponCreate, CouponUpdate, CouponRead, TradelistingCreate, TradelistingUpdate, TradelistingRead, TradeBidCreate, TradeBidUpdate, TradeBidRead, TradeTransactionCreate, TradeTransactionUpdate, TradeTransactionRead, CardPriceHistoryCreate, CardPriceHistoryUpdate, CardPriceHistoryRead, TradeDisputeCreate, TradeDisputeUpdate, TradeDisputeRead

router_product = APIRouter(prefix="/api/products", tags=["Product"])

@router_product.get("", response_model=list[ProductRead])
def list_products(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[Product]:
    return db.query(Product).offset(skip).limit(limit).all()

@router_product.post("", response_model=ProductRead, status_code=status.HTTP_201_CREATED)
def create_product(data: ProductCreate, db: Session = Depends(get_db)) -> Product:
    obj = Product(**data.model_dump(exclude_unset=True))
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_product.get("/{item_id}", response_model=ProductRead)
def get_product(item_id: int, db: Session = Depends(get_db)) -> Product:
    obj = db.query(Product).filter(Product.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Product not found")
    return obj

@router_product.put("/{item_id}", response_model=ProductRead)
def update_product(item_id: int, data: ProductUpdate, db: Session = Depends(get_db)) -> Product:
    obj = db.query(Product).filter(Product.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Product not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, key, value)
    db.commit()
    db.refresh(obj)
    return obj

@router_product.patch("/{item_id}", response_model=ProductRead)
def patch_product(item_id: int, data: ProductUpdate, db: Session = Depends(get_db)) -> Product:
    return update_product(item_id, data, db)

@router_product.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_product(item_id: int, db: Session = Depends(get_db)) -> None:
    obj = db.query(Product).filter(Product.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Product not found")
    db.delete(obj)
    db.commit()

router_order = APIRouter(prefix="/api/orders", tags=["Order"])

@router_order.get("", response_model=list[OrderRead])
def list_orders(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[Order]:
    return db.query(Order).offset(skip).limit(limit).all()

@router_order.post("", response_model=OrderRead, status_code=status.HTTP_201_CREATED)
def create_order(data: OrderCreate, db: Session = Depends(get_db)) -> Order:
    obj = Order(**data.model_dump(exclude_unset=True))
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_order.get("/{item_id}", response_model=OrderRead)
def get_order(item_id: int, db: Session = Depends(get_db)) -> Order:
    obj = db.query(Order).filter(Order.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Order not found")
    return obj

@router_order.put("/{item_id}", response_model=OrderRead)
def update_order(item_id: int, data: OrderUpdate, db: Session = Depends(get_db)) -> Order:
    obj = db.query(Order).filter(Order.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Order not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, key, value)
    db.commit()
    db.refresh(obj)
    return obj

@router_order.patch("/{item_id}", response_model=OrderRead)
def patch_order(item_id: int, data: OrderUpdate, db: Session = Depends(get_db)) -> Order:
    return update_order(item_id, data, db)

@router_order.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_order(item_id: int, db: Session = Depends(get_db)) -> None:
    obj = db.query(Order).filter(Order.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Order not found")
    db.delete(obj)
    db.commit()

router_order_item = APIRouter(prefix="/api/order_items", tags=["Order Item"])

@router_order_item.get("", response_model=list[OrderItemRead])
def list_order_items(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[OrderItem]:
    return db.query(OrderItem).offset(skip).limit(limit).all()

@router_order_item.post("", response_model=OrderItemRead, status_code=status.HTTP_201_CREATED)
def create_order_item(data: OrderItemCreate, db: Session = Depends(get_db)) -> OrderItem:
    obj = OrderItem(**data.model_dump(exclude_unset=True))
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_order_item.get("/{item_id}", response_model=OrderItemRead)
def get_order_item(item_id: int, db: Session = Depends(get_db)) -> OrderItem:
    obj = db.query(OrderItem).filter(OrderItem.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="OrderItem not found")
    return obj

@router_order_item.put("/{item_id}", response_model=OrderItemRead)
def update_order_item(item_id: int, data: OrderItemUpdate, db: Session = Depends(get_db)) -> OrderItem:
    obj = db.query(OrderItem).filter(OrderItem.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="OrderItem not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, key, value)
    db.commit()
    db.refresh(obj)
    return obj

@router_order_item.patch("/{item_id}", response_model=OrderItemRead)
def patch_order_item(item_id: int, data: OrderItemUpdate, db: Session = Depends(get_db)) -> OrderItem:
    return update_order_item(item_id, data, db)

@router_order_item.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_order_item(item_id: int, db: Session = Depends(get_db)) -> None:
    obj = db.query(OrderItem).filter(OrderItem.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="OrderItem not found")
    db.delete(obj)
    db.commit()

router_coupon = APIRouter(prefix="/api/coupons", tags=["Coupon"])

@router_coupon.get("", response_model=list[CouponRead])
def list_coupons(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[Coupon]:
    return db.query(Coupon).offset(skip).limit(limit).all()

@router_coupon.post("", response_model=CouponRead, status_code=status.HTTP_201_CREATED)
def create_coupon(data: CouponCreate, db: Session = Depends(get_db)) -> Coupon:
    obj = Coupon(**data.model_dump(exclude_unset=True))
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_coupon.get("/{item_id}", response_model=CouponRead)
def get_coupon(item_id: int, db: Session = Depends(get_db)) -> Coupon:
    obj = db.query(Coupon).filter(Coupon.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Coupon not found")
    return obj

@router_coupon.put("/{item_id}", response_model=CouponRead)
def update_coupon(item_id: int, data: CouponUpdate, db: Session = Depends(get_db)) -> Coupon:
    obj = db.query(Coupon).filter(Coupon.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Coupon not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, key, value)
    db.commit()
    db.refresh(obj)
    return obj

@router_coupon.patch("/{item_id}", response_model=CouponRead)
def patch_coupon(item_id: int, data: CouponUpdate, db: Session = Depends(get_db)) -> Coupon:
    return update_coupon(item_id, data, db)

@router_coupon.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_coupon(item_id: int, db: Session = Depends(get_db)) -> None:
    obj = db.query(Coupon).filter(Coupon.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Coupon not found")
    db.delete(obj)
    db.commit()

router_tradelisting = APIRouter(prefix="/api/tradelistings", tags=["Tradelisting"])

@router_tradelisting.get("", response_model=list[TradelistingRead])
def list_tradelistings(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[Tradelisting]:
    return db.query(Tradelisting).offset(skip).limit(limit).all()

@router_tradelisting.post("", response_model=TradelistingRead, status_code=status.HTTP_201_CREATED)
def create_tradelisting(data: TradelistingCreate, db: Session = Depends(get_db)) -> Tradelisting:
    obj = Tradelisting(**data.model_dump(exclude_unset=True))
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_tradelisting.get("/{item_id}", response_model=TradelistingRead)
def get_tradelisting(item_id: int, db: Session = Depends(get_db)) -> Tradelisting:
    obj = db.query(Tradelisting).filter(Tradelisting.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Tradelisting not found")
    return obj

@router_tradelisting.put("/{item_id}", response_model=TradelistingRead)
def update_tradelisting(item_id: int, data: TradelistingUpdate, db: Session = Depends(get_db)) -> Tradelisting:
    obj = db.query(Tradelisting).filter(Tradelisting.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Tradelisting not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, key, value)
    db.commit()
    db.refresh(obj)
    return obj

@router_tradelisting.patch("/{item_id}", response_model=TradelistingRead)
def patch_tradelisting(item_id: int, data: TradelistingUpdate, db: Session = Depends(get_db)) -> Tradelisting:
    return update_tradelisting(item_id, data, db)

@router_tradelisting.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_tradelisting(item_id: int, db: Session = Depends(get_db)) -> None:
    obj = db.query(Tradelisting).filter(Tradelisting.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Tradelisting not found")
    db.delete(obj)
    db.commit()

router_trade_bid = APIRouter(prefix="/api/trade_bids", tags=["Trade Bid"])

@router_trade_bid.get("", response_model=list[TradeBidRead])
def list_trade_bids(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[TradeBid]:
    return db.query(TradeBid).offset(skip).limit(limit).all()

@router_trade_bid.post("", response_model=TradeBidRead, status_code=status.HTTP_201_CREATED)
def create_trade_bid(data: TradeBidCreate, db: Session = Depends(get_db)) -> TradeBid:
    obj = TradeBid(**data.model_dump(exclude_unset=True))
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_trade_bid.get("/{item_id}", response_model=TradeBidRead)
def get_trade_bid(item_id: int, db: Session = Depends(get_db)) -> TradeBid:
    obj = db.query(TradeBid).filter(TradeBid.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TradeBid not found")
    return obj

@router_trade_bid.put("/{item_id}", response_model=TradeBidRead)
def update_trade_bid(item_id: int, data: TradeBidUpdate, db: Session = Depends(get_db)) -> TradeBid:
    obj = db.query(TradeBid).filter(TradeBid.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TradeBid not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, key, value)
    db.commit()
    db.refresh(obj)
    return obj

@router_trade_bid.patch("/{item_id}", response_model=TradeBidRead)
def patch_trade_bid(item_id: int, data: TradeBidUpdate, db: Session = Depends(get_db)) -> TradeBid:
    return update_trade_bid(item_id, data, db)

@router_trade_bid.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_trade_bid(item_id: int, db: Session = Depends(get_db)) -> None:
    obj = db.query(TradeBid).filter(TradeBid.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TradeBid not found")
    db.delete(obj)
    db.commit()

router_trade_transaction = APIRouter(prefix="/api/trade_transactions", tags=["Trade Transaction"])

@router_trade_transaction.get("", response_model=list[TradeTransactionRead])
def list_trade_transactions(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[TradeTransaction]:
    return db.query(TradeTransaction).offset(skip).limit(limit).all()

@router_trade_transaction.post("", response_model=TradeTransactionRead, status_code=status.HTTP_201_CREATED)
def create_trade_transaction(data: TradeTransactionCreate, db: Session = Depends(get_db)) -> TradeTransaction:
    obj = TradeTransaction(**data.model_dump(exclude_unset=True))
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_trade_transaction.get("/{item_id}", response_model=TradeTransactionRead)
def get_trade_transaction(item_id: int, db: Session = Depends(get_db)) -> TradeTransaction:
    obj = db.query(TradeTransaction).filter(TradeTransaction.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TradeTransaction not found")
    return obj

@router_trade_transaction.put("/{item_id}", response_model=TradeTransactionRead)
def update_trade_transaction(item_id: int, data: TradeTransactionUpdate, db: Session = Depends(get_db)) -> TradeTransaction:
    obj = db.query(TradeTransaction).filter(TradeTransaction.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TradeTransaction not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, key, value)
    db.commit()
    db.refresh(obj)
    return obj

@router_trade_transaction.patch("/{item_id}", response_model=TradeTransactionRead)
def patch_trade_transaction(item_id: int, data: TradeTransactionUpdate, db: Session = Depends(get_db)) -> TradeTransaction:
    return update_trade_transaction(item_id, data, db)

@router_trade_transaction.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_trade_transaction(item_id: int, db: Session = Depends(get_db)) -> None:
    obj = db.query(TradeTransaction).filter(TradeTransaction.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TradeTransaction not found")
    db.delete(obj)
    db.commit()

router_card_price_history = APIRouter(prefix="/api/card_price_histories", tags=["Card Price History"])

@router_card_price_history.get("", response_model=list[CardPriceHistoryRead])
def list_card_price_histories(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[CardPriceHistory]:
    return db.query(CardPriceHistory).offset(skip).limit(limit).all()

@router_card_price_history.post("", response_model=CardPriceHistoryRead, status_code=status.HTTP_201_CREATED)
def create_card_price_history(data: CardPriceHistoryCreate, db: Session = Depends(get_db)) -> CardPriceHistory:
    obj = CardPriceHistory(**data.model_dump(exclude_unset=True))
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_card_price_history.get("/{item_id}", response_model=CardPriceHistoryRead)
def get_card_price_history(item_id: int, db: Session = Depends(get_db)) -> CardPriceHistory:
    obj = db.query(CardPriceHistory).filter(CardPriceHistory.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="CardPriceHistory not found")
    return obj

@router_card_price_history.put("/{item_id}", response_model=CardPriceHistoryRead)
def update_card_price_history(item_id: int, data: CardPriceHistoryUpdate, db: Session = Depends(get_db)) -> CardPriceHistory:
    obj = db.query(CardPriceHistory).filter(CardPriceHistory.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="CardPriceHistory not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, key, value)
    db.commit()
    db.refresh(obj)
    return obj

@router_card_price_history.patch("/{item_id}", response_model=CardPriceHistoryRead)
def patch_card_price_history(item_id: int, data: CardPriceHistoryUpdate, db: Session = Depends(get_db)) -> CardPriceHistory:
    return update_card_price_history(item_id, data, db)

@router_card_price_history.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_card_price_history(item_id: int, db: Session = Depends(get_db)) -> None:
    obj = db.query(CardPriceHistory).filter(CardPriceHistory.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="CardPriceHistory not found")
    db.delete(obj)
    db.commit()

router_trade_dispute = APIRouter(prefix="/api/trade_disputes", tags=["Trade Dispute"])

@router_trade_dispute.get("", response_model=list[TradeDisputeRead])
def list_trade_disputes(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[TradeDispute]:
    return db.query(TradeDispute).offset(skip).limit(limit).all()

@router_trade_dispute.post("", response_model=TradeDisputeRead, status_code=status.HTTP_201_CREATED)
def create_trade_dispute(data: TradeDisputeCreate, db: Session = Depends(get_db)) -> TradeDispute:
    obj = TradeDispute(**data.model_dump(exclude_unset=True))
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_trade_dispute.get("/{item_id}", response_model=TradeDisputeRead)
def get_trade_dispute(item_id: int, db: Session = Depends(get_db)) -> TradeDispute:
    obj = db.query(TradeDispute).filter(TradeDispute.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TradeDispute not found")
    return obj

@router_trade_dispute.put("/{item_id}", response_model=TradeDisputeRead)
def update_trade_dispute(item_id: int, data: TradeDisputeUpdate, db: Session = Depends(get_db)) -> TradeDispute:
    obj = db.query(TradeDispute).filter(TradeDispute.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TradeDispute not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, key, value)
    db.commit()
    db.refresh(obj)
    return obj

@router_trade_dispute.patch("/{item_id}", response_model=TradeDisputeRead)
def patch_trade_dispute(item_id: int, data: TradeDisputeUpdate, db: Session = Depends(get_db)) -> TradeDispute:
    return update_trade_dispute(item_id, data, db)

@router_trade_dispute.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_trade_dispute(item_id: int, db: Session = Depends(get_db)) -> None:
    obj = db.query(TradeDispute).filter(TradeDispute.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TradeDispute not found")
    db.delete(obj)
    db.commit()
