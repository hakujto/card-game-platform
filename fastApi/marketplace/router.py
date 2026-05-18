from typing import Sequence

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.db import get_db
from .models import Product, Order, OrderItem, Coupon, TradeListing, TradeBid, TradeTransaction, CardPriceHistory, TradeDispute
from .schemas import ProductCreate, ProductUpdate, ProductRead, OrderCreate, OrderUpdate, OrderRead, OrderItemCreate, OrderItemUpdate, OrderItemRead, CouponCreate, CouponUpdate, CouponRead, TradeListingCreate, TradeListingUpdate, TradeListingRead, TradeBidCreate, TradeBidUpdate, TradeBidRead, TradeTransactionCreate, TradeTransactionUpdate, TradeTransactionRead, CardPriceHistoryCreate, CardPriceHistoryUpdate, CardPriceHistoryRead, TradeDisputeCreate, TradeDisputeUpdate, TradeDisputeRead

def _validate_product(obj: Product) -> None:
    errors: list[str] = []
    errors.extend(obj.validate_rules())
    if errors:
        raise HTTPException(status_code=422, detail=errors)


router_product = APIRouter(prefix="/api/products", tags=["Product"])

@router_product.get("", response_model=list[ProductRead])
def list_products(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[Product]:
    return db.query(Product).offset(skip).limit(limit).all()

@router_product.post("", response_model=ProductRead, status_code=status.HTTP_201_CREATED)
def create_product(data: ProductCreate, db: Session = Depends(get_db)) -> Product:
    obj = Product(**data.model_dump(exclude_unset=True))
    _validate_product(obj)
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
    _validate_product(obj)
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

@router_product.post("/{item_id}/activate", status_code=status.HTTP_204_NO_CONTENT)
def activate_product(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(Product).filter(Product.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Product not found")
    obj.activate()
    db.commit()

@router_product.post("/{item_id}/deactivate", status_code=status.HTTP_204_NO_CONTENT)
def deactivate_product(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(Product).filter(Product.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Product not found")
    obj.deactivate()
    db.commit()

@router_product.patch("/{item_id}/discount", response_model=float)
def apply_discount_product(item_id: int, body: dict = {}, db: Session = Depends(get_db)):
    obj = db.query(Product).filter(Product.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Product not found")
    result = obj.apply_discount(body.get("percent"))
    db.commit()
    return result

@router_product.post("/{item_id}/restock", status_code=status.HTTP_204_NO_CONTENT)
def restock_product(item_id: int, body: dict = {}, db: Session = Depends(get_db)):
    obj = db.query(Product).filter(Product.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Product not found")
    obj.restock(body.get("quantity"))
    db.commit()

@router_product.get("/{item_id}/effective-price", response_model=float)
def effective_price_product(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(Product).filter(Product.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Product not found")
    result = obj.effective_price()
    db.commit()
    return result

@router_product.get("/{item_id}/in-stock", response_model=bool)
def is_in_stock_product(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(Product).filter(Product.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Product not found")
    result = obj.is_in_stock()
    db.commit()
    return result

def _validate_order(obj: Order) -> None:
    errors: list[str] = []
    errors.extend(obj.validate_rules())
    errors.extend(obj.validate_implies())
    if errors:
        raise HTTPException(status_code=422, detail=errors)


router_order = APIRouter(prefix="/api/orders", tags=["Order"])

@router_order.get("", response_model=list[OrderRead])
def list_orders(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[Order]:
    return db.query(Order).offset(skip).limit(limit).all()

@router_order.post("", response_model=OrderRead, status_code=status.HTTP_201_CREATED)
def create_order(data: OrderCreate, db: Session = Depends(get_db)) -> Order:
    obj = Order(**data.model_dump(exclude_unset=True))
    _validate_order(obj)
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
    _validate_order(obj)
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

@router_order.delete("/{item_id}/cancel", status_code=status.HTTP_204_NO_CONTENT)
def cancel_order(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(Order).filter(Order.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Order not found")
    obj.cancel()
    db.commit()

@router_order.post("/{item_id}/pay", response_model=bool)
def pay_order(item_id: int, body: dict = {}, db: Session = Depends(get_db)):
    obj = db.query(Order).filter(Order.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Order not found")
    result = obj.pay(body.get("payment_ref"))
    db.commit()
    return result

@router_order.get("/{item_id}/total", response_model=float)
def calculate_total_order(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(Order).filter(Order.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Order not found")
    result = obj.calculate_total()
    db.commit()
    return result

@router_order.patch("/{item_id}/discount", response_model=float)
def apply_discount_order(item_id: int, body: dict = {}, db: Session = Depends(get_db)):
    obj = db.query(Order).filter(Order.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Order not found")
    result = obj.apply_discount(body.get("percent"))
    db.commit()
    return result

@router_order.post("/{item_id}/refund", status_code=status.HTTP_204_NO_CONTENT)
def refund_order(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(Order).filter(Order.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Order not found")
    obj.refund()
    db.commit()

def _validate_order_item(obj: OrderItem) -> None:
    errors: list[str] = []
    errors.extend(obj.validate_rules())
    if errors:
        raise HTTPException(status_code=422, detail=errors)


router_order_item = APIRouter(prefix="/api/order_items", tags=["Order Item"])

@router_order_item.get("", response_model=list[OrderItemRead])
def list_order_items(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[OrderItem]:
    return db.query(OrderItem).offset(skip).limit(limit).all()

@router_order_item.post("", response_model=OrderItemRead, status_code=status.HTTP_201_CREATED)
def create_order_item(data: OrderItemCreate, db: Session = Depends(get_db)) -> OrderItem:
    obj = OrderItem(**data.model_dump(exclude_unset=True))
    _validate_order_item(obj)
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
    _validate_order_item(obj)
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

@router_order_item.get("/{item_id}/api/order-items/{id}/total", response_model=float)
def line_total_order_item(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(OrderItem).filter(OrderItem.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="OrderItem not found")
    result = obj.line_total()
    db.commit()
    return result

def _validate_coupon(obj: Coupon) -> None:
    errors: list[str] = []
    errors.extend(obj.validate_rules())
    errors.extend(obj.validate_implies())
    if errors:
        raise HTTPException(status_code=422, detail=errors)


router_coupon = APIRouter(prefix="/api/coupons", tags=["Coupon"])

@router_coupon.get("", response_model=list[CouponRead])
def list_coupons(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[Coupon]:
    return db.query(Coupon).offset(skip).limit(limit).all()

@router_coupon.post("", response_model=CouponRead, status_code=status.HTTP_201_CREATED)
def create_coupon(data: CouponCreate, db: Session = Depends(get_db)) -> Coupon:
    obj = Coupon(**data.model_dump(exclude_unset=True))
    _validate_coupon(obj)
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
    _validate_coupon(obj)
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

@router_coupon.get("/{item_id}/valid", response_model=bool)
def is_valid_coupon(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(Coupon).filter(Coupon.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Coupon not found")
    result = obj.is_valid()
    db.commit()
    return result

@router_coupon.get("/{item_id}/applicable", response_model=bool)
def is_applicable_to_order_coupon(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(Coupon).filter(Coupon.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Coupon not found")
    result = obj.is_applicable_to_order()
    db.commit()
    return result

@router_coupon.post("/{item_id}/redeem", status_code=status.HTTP_204_NO_CONTENT)
def redeem_coupon(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(Coupon).filter(Coupon.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Coupon not found")
    obj.redeem()
    db.commit()

@router_coupon.post("/{item_id}/deactivate", status_code=status.HTTP_204_NO_CONTENT)
def deactivate_coupon(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(Coupon).filter(Coupon.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Coupon not found")
    obj.deactivate()
    db.commit()

def _validate_trade_listing(obj: TradeListing) -> None:
    errors: list[str] = []
    errors.extend(obj.validate_rules())
    errors.extend(obj.validate_implies())
    if errors:
        raise HTTPException(status_code=422, detail=errors)


router_trade_listing = APIRouter(prefix="/api/trade_listings", tags=["Trade Listing"])

@router_trade_listing.get("", response_model=list[TradeListingRead])
def list_trade_listings(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[TradeListing]:
    return db.query(TradeListing).offset(skip).limit(limit).all()

@router_trade_listing.post("", response_model=TradeListingRead, status_code=status.HTTP_201_CREATED)
def create_trade_listing(data: TradeListingCreate, db: Session = Depends(get_db)) -> TradeListing:
    obj = TradeListing(**data.model_dump(exclude_unset=True))
    _validate_trade_listing(obj)
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_trade_listing.get("/{item_id}", response_model=TradeListingRead)
def get_trade_listing(item_id: int, db: Session = Depends(get_db)) -> TradeListing:
    obj = db.query(TradeListing).filter(TradeListing.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TradeListing not found")
    return obj

@router_trade_listing.put("/{item_id}", response_model=TradeListingRead)
def update_trade_listing(item_id: int, data: TradeListingUpdate, db: Session = Depends(get_db)) -> TradeListing:
    obj = db.query(TradeListing).filter(TradeListing.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TradeListing not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, key, value)
    _validate_trade_listing(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_trade_listing.patch("/{item_id}", response_model=TradeListingRead)
def patch_trade_listing(item_id: int, data: TradeListingUpdate, db: Session = Depends(get_db)) -> TradeListing:
    return update_trade_listing(item_id, data, db)

@router_trade_listing.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_trade_listing(item_id: int, db: Session = Depends(get_db)) -> None:
    obj = db.query(TradeListing).filter(TradeListing.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TradeListing not found")
    db.delete(obj)
    db.commit()

@router_trade_listing.post("/{item_id}/api/trade-listings/{id}/close", status_code=status.HTTP_204_NO_CONTENT)
def close_trade_listing(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(TradeListing).filter(TradeListing.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TradeListing not found")
    obj.close()
    db.commit()

@router_trade_listing.patch("/{item_id}/api/trade-listings/{id}/extend", status_code=status.HTTP_204_NO_CONTENT)
def extend_trade_listing(item_id: int, body: dict = {}, db: Session = Depends(get_db)):
    obj = db.query(TradeListing).filter(TradeListing.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TradeListing not found")
    obj.extend(body.get("days"))
    db.commit()

@router_trade_listing.delete("/{item_id}/api/trade-listings/{id}/cancel", status_code=status.HTTP_204_NO_CONTENT)
def cancel_trade_listing(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(TradeListing).filter(TradeListing.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TradeListing not found")
    obj.cancel()
    db.commit()

@router_trade_listing.get("/{item_id}/api/trade-listings/{id}/expired", response_model=bool)
def is_expired_trade_listing(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(TradeListing).filter(TradeListing.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TradeListing not found")
    result = obj.is_expired()
    db.commit()
    return result

@router_trade_listing.post("/{item_id}/api/trade-listings/{id}/finalize", status_code=status.HTTP_204_NO_CONTENT)
def finalize_auction_trade_listing(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(TradeListing).filter(TradeListing.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TradeListing not found")
    obj.finalize_auction()
    db.commit()

def _validate_trade_bid(obj: TradeBid) -> None:
    errors: list[str] = []
    errors.extend(obj.validate_rules())
    if errors:
        raise HTTPException(status_code=422, detail=errors)


router_trade_bid = APIRouter(prefix="/api/trade_bids", tags=["Trade Bid"])

@router_trade_bid.get("", response_model=list[TradeBidRead])
def list_trade_bids(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[TradeBid]:
    return db.query(TradeBid).offset(skip).limit(limit).all()

@router_trade_bid.post("", response_model=TradeBidRead, status_code=status.HTTP_201_CREATED)
def create_trade_bid(data: TradeBidCreate, db: Session = Depends(get_db)) -> TradeBid:
    obj = TradeBid(**data.model_dump(exclude_unset=True))
    _validate_trade_bid(obj)
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
    _validate_trade_bid(obj)
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

@router_trade_bid.get("/{item_id}/api/bids/{id}/outbid", response_model=bool)
def outbid_by_trade_bid(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(TradeBid).filter(TradeBid.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TradeBid not found")
    result = obj.outbid_by()
    db.commit()
    return result

@router_trade_bid.delete("/{item_id}/api/bids/{id}", status_code=status.HTTP_204_NO_CONTENT)
def retract_trade_bid(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(TradeBid).filter(TradeBid.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TradeBid not found")
    obj.retract()
    db.commit()

def _validate_trade_transaction(obj: TradeTransaction) -> None:
    errors: list[str] = []
    errors.extend(obj.validate_rules())
    errors.extend(obj.validate_implies())
    if errors:
        raise HTTPException(status_code=422, detail=errors)


router_trade_transaction = APIRouter(prefix="/api/trade_transactions", tags=["Trade Transaction"])

@router_trade_transaction.get("", response_model=list[TradeTransactionRead])
def list_trade_transactions(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[TradeTransaction]:
    return db.query(TradeTransaction).offset(skip).limit(limit).all()

@router_trade_transaction.post("", response_model=TradeTransactionRead, status_code=status.HTTP_201_CREATED)
def create_trade_transaction(data: TradeTransactionCreate, db: Session = Depends(get_db)) -> TradeTransaction:
    obj = TradeTransaction(**data.model_dump(exclude_unset=True))
    _validate_trade_transaction(obj)
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
    _validate_trade_transaction(obj)
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

@router_trade_transaction.post("/{item_id}/api/transactions/{id}/complete", status_code=status.HTTP_204_NO_CONTENT)
def complete_trade_transaction(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(TradeTransaction).filter(TradeTransaction.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TradeTransaction not found")
    obj.complete()
    db.commit()

@router_trade_transaction.post("/{item_id}/api/transactions/{id}/refund", status_code=status.HTTP_204_NO_CONTENT)
def refund_trade_transaction(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(TradeTransaction).filter(TradeTransaction.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TradeTransaction not found")
    obj.refund()
    db.commit()

@router_trade_transaction.post("/{item_id}/api/transactions/{id}/dispute", status_code=status.HTTP_204_NO_CONTENT)
def open_dispute_trade_transaction(item_id: int, body: dict = {}, db: Session = Depends(get_db)):
    obj = db.query(TradeTransaction).filter(TradeTransaction.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TradeTransaction not found")
    obj.open_dispute(body.get("reason"))
    db.commit()

@router_trade_transaction.get("/{item_id}/api/transactions/{id}/seller-net", response_model=float)
def seller_net_trade_transaction(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(TradeTransaction).filter(TradeTransaction.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TradeTransaction not found")
    result = obj.seller_net()
    db.commit()
    return result

def _validate_card_price_history(obj: CardPriceHistory) -> None:
    errors: list[str] = []
    errors.extend(obj.validate_rules())
    if errors:
        raise HTTPException(status_code=422, detail=errors)


router_card_price_history = APIRouter(prefix="/api/card_price_histories", tags=["Card Price History"])

@router_card_price_history.get("", response_model=list[CardPriceHistoryRead])
def list_card_price_histories(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[CardPriceHistory]:
    return db.query(CardPriceHistory).offset(skip).limit(limit).all()

@router_card_price_history.post("", response_model=CardPriceHistoryRead, status_code=status.HTTP_201_CREATED)
def create_card_price_history(data: CardPriceHistoryCreate, db: Session = Depends(get_db)) -> CardPriceHistory:
    obj = CardPriceHistory(**data.model_dump(exclude_unset=True))
    _validate_card_price_history(obj)
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
    _validate_card_price_history(obj)
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

@router_card_price_history.get("/{item_id}/api/price-history/{id}/change", response_model=float)
def price_change_percent_card_price_history(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(CardPriceHistory).filter(CardPriceHistory.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="CardPriceHistory not found")
    result = obj.price_change_percent()
    db.commit()
    return result

@router_card_price_history.get("/{item_id}/api/price-history/{id}/spike", response_model=bool)
def is_price_spike_card_price_history(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(CardPriceHistory).filter(CardPriceHistory.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="CardPriceHistory not found")
    result = obj.is_price_spike()
    db.commit()
    return result

def _validate_trade_dispute(obj: TradeDispute) -> None:
    errors: list[str] = []
    errors.extend(obj.validate_implies())
    if errors:
        raise HTTPException(status_code=422, detail=errors)


router_trade_dispute = APIRouter(prefix="/api/trade_disputes", tags=["Trade Dispute"])

@router_trade_dispute.get("", response_model=list[TradeDisputeRead])
def list_trade_disputes(
    skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[TradeDispute]:
    return db.query(TradeDispute).offset(skip).limit(limit).all()

@router_trade_dispute.post("", response_model=TradeDisputeRead, status_code=status.HTTP_201_CREATED)
def create_trade_dispute(data: TradeDisputeCreate, db: Session = Depends(get_db)) -> TradeDispute:
    obj = TradeDispute(**data.model_dump(exclude_unset=True))
    _validate_trade_dispute(obj)
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
    _validate_trade_dispute(obj)
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

@router_trade_dispute.post("/{item_id}/api/disputes/{id}/escalate", status_code=status.HTTP_204_NO_CONTENT)
def escalate_trade_dispute(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(TradeDispute).filter(TradeDispute.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TradeDispute not found")
    obj.escalate()
    db.commit()

@router_trade_dispute.post("/{item_id}/api/disputes/{id}/resolve", status_code=status.HTTP_204_NO_CONTENT)
def resolve_trade_dispute(item_id: int, body: dict = {}, db: Session = Depends(get_db)):
    obj = db.query(TradeDispute).filter(TradeDispute.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TradeDispute not found")
    obj.resolve(body.get("resolution_text"))
    db.commit()

@router_trade_dispute.post("/{item_id}/api/disputes/{id}/review", status_code=status.HTTP_204_NO_CONTENT)
def review_trade_dispute(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(TradeDispute).filter(TradeDispute.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TradeDispute not found")
    obj.review()
    db.commit()
