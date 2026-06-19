from typing import Sequence

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.db import get_db
from app.auth import get_current_user
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
    q: str | None = None, skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[Product]:
    query = db.query(Product)
    if q:
        from sqlalchemy import or_
        query = query.filter(or_(Product.name.ilike(f"%{q}%"), Product.description.ilike(f"%{q}%")))
    return query.offset(skip).limit(limit).all()

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

@router_order.patch("/{item_id}/transitions/pending-to-paid", response_model=OrderRead)
def transition_pending_to_paid_order(item_id: int, db: Session = Depends(get_db)) -> Order:
    from fastapi import HTTPException
    obj = db.query(Order).filter(Order.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Order not found")
    try:
        obj.assert_transition("Paid")
    except ValueError as e:
        raise HTTPException(status_code=409, detail=str(e))
    if obj.payment_method is None:
        raise HTTPException(status_code=422, detail="payment_method is required for Pending -> Paid")
    obj.status = "Paid"
    obj.process_payment()  # @after
    db.commit()
    db.refresh(obj)
    return obj

@router_order.patch("/{item_id}/transitions/paid-to-processing", response_model=OrderRead)
def transition_paid_to_processing_order(item_id: int, db: Session = Depends(get_db), current_user=Depends(get_current_user)) -> Order:
    from fastapi import HTTPException
    obj = db.query(Order).filter(Order.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Order not found")
    if getattr(current_user, "role", None) not in ["Admin", "Staff"]:
        raise HTTPException(status_code=403, detail="Insufficient role for transition Paid -> Processing")
    try:
        obj.assert_transition("Processing")
    except ValueError as e:
        raise HTTPException(status_code=409, detail=str(e))
    obj.status = "Processing"
    db.commit()
    db.refresh(obj)
    return obj

@router_order.patch("/{item_id}/transitions/processing-to-shipped", response_model=OrderRead)
def transition_processing_to_shipped_order(item_id: int, db: Session = Depends(get_db), current_user=Depends(get_current_user)) -> Order:
    from fastapi import HTTPException
    obj = db.query(Order).filter(Order.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Order not found")
    if getattr(current_user, "role", None) not in ["Admin", "Staff"]:
        raise HTTPException(status_code=403, detail="Insufficient role for transition Processing -> Shipped")
    try:
        obj.assert_transition("Shipped")
    except ValueError as e:
        raise HTTPException(status_code=409, detail=str(e))
    if obj.tracking_number is None:
        raise HTTPException(status_code=422, detail="tracking_number is required for Processing -> Shipped")
    obj.status = "Shipped"
    obj.notify_shipped()  # @after
    db.commit()
    db.refresh(obj)
    return obj

@router_order.patch("/{item_id}/transitions/shipped-to-completed", response_model=OrderRead)
def transition_shipped_to_completed_order(item_id: int, db: Session = Depends(get_db), current_user=Depends(get_current_user)) -> Order:
    from fastapi import HTTPException
    obj = db.query(Order).filter(Order.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Order not found")
    if getattr(current_user, "role", None) not in ["Admin", "Staff"]:
        raise HTTPException(status_code=403, detail="Insufficient role for transition Shipped -> Completed")
    try:
        obj.assert_transition("Completed")
    except ValueError as e:
        raise HTTPException(status_code=409, detail=str(e))
    obj.status = "Completed"
    db.commit()
    db.refresh(obj)
    return obj

@router_order.patch("/{item_id}/transitions/pending-to-cancelled", response_model=OrderRead)
def transition_pending_to_cancelled_order(item_id: int, db: Session = Depends(get_db)) -> Order:
    from fastapi import HTTPException
    obj = db.query(Order).filter(Order.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Order not found")
    try:
        obj.assert_transition("Cancelled")
    except ValueError as e:
        raise HTTPException(status_code=409, detail=str(e))
    obj.status = "Cancelled"
    obj.cancel()  # @after
    db.commit()
    db.refresh(obj)
    return obj

@router_order.patch("/{item_id}/transitions/paid-to-cancelled", response_model=OrderRead)
def transition_paid_to_cancelled_order(item_id: int, db: Session = Depends(get_db), current_user=Depends(get_current_user)) -> Order:
    from fastapi import HTTPException
    obj = db.query(Order).filter(Order.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Order not found")
    if getattr(current_user, "role", None) not in ["Admin", "Staff"]:
        raise HTTPException(status_code=403, detail="Insufficient role for transition Paid -> Cancelled")
    try:
        obj.assert_transition("Cancelled")
    except ValueError as e:
        raise HTTPException(status_code=409, detail=str(e))
    obj.status = "Cancelled"
    obj.cancel()  # @after
    db.commit()
    db.refresh(obj)
    return obj

@router_order.patch("/{item_id}/transitions/completed-to-refunded", response_model=OrderRead)
def transition_completed_to_refunded_order(item_id: int, db: Session = Depends(get_db), current_user=Depends(get_current_user)) -> Order:
    from fastapi import HTTPException
    obj = db.query(Order).filter(Order.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Order not found")
    if getattr(current_user, "role", None) not in ["Admin"]:
        raise HTTPException(status_code=403, detail="Insufficient role for transition Completed -> Refunded")
    try:
        obj.assert_transition("Refunded")
    except ValueError as e:
        raise HTTPException(status_code=409, detail=str(e))
    obj.status = "Refunded"
    obj.refund()  # @after
    db.commit()
    db.refresh(obj)
    return obj

@router_order.patch("/{item_id}/transitions/refunded-to-completed", response_model=OrderRead)
def transition_refunded_to_completed_order(item_id: int, db: Session = Depends(get_db)) -> Order:
    from fastapi import HTTPException
    obj = db.query(Order).filter(Order.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Order not found")
    raise HTTPException(status_code=409, detail="Transition Refunded -> Completed is not allowed")

@router_order.patch("/{item_id}/transitions/completed-to-cancelled", response_model=OrderRead)
def transition_completed_to_cancelled_order(item_id: int, db: Session = Depends(get_db)) -> Order:
    from fastapi import HTTPException
    obj = db.query(Order).filter(Order.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Order not found")
    raise HTTPException(status_code=409, detail="Transition Completed -> Cancelled is not allowed")

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

@router_order.post("/{item_id}/process-payment", response_model=bool)
def process_payment_order(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(Order).filter(Order.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="Order not found")
    result = obj.process_payment()
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
    q: str | None = None, skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[Coupon]:
    query = db.query(Coupon)
    if q:
        from sqlalchemy import or_
        query = query.filter(or_(Coupon.code.ilike(f"%{q}%")))
    return query.offset(skip).limit(limit).all()

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
    q: str | None = None, skip: int = 0, limit: int = 100, db: Session = Depends(get_db)
) -> Sequence[TradeListing]:
    query = db.query(TradeListing)
    if q:
        from sqlalchemy import or_
        query = query.filter(or_(TradeListing.description.ilike(f"%{q}%")))
    return query.offset(skip).limit(limit).all()

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

@router_trade_listing.patch("/{item_id}", response_model=TradeListingRead)
def patch_trade_listing(item_id: int, data: TradeListingUpdate, db: Session = Depends(get_db)) -> TradeListing:
    obj = db.query(TradeListing).filter(TradeListing.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TradeListing not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(obj, key, value)
    _validate_trade_listing(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router_trade_listing.patch("/{item_id}/transitions/pending-to-active", response_model=TradeListingRead)
def transition_pending_to_active_trade_listing(item_id: int, db: Session = Depends(get_db), current_user=Depends(get_current_user)) -> TradeListing:
    from fastapi import HTTPException
    obj = db.query(TradeListing).filter(TradeListing.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TradeListing not found")
    if getattr(current_user, "role", None) not in ["Seller"]:
        raise HTTPException(status_code=403, detail="Insufficient role for transition Pending -> Active")
    try:
        obj.assert_transition("Active")
    except ValueError as e:
        raise HTTPException(status_code=409, detail=str(e))
    if obj.quantity is None:
        raise HTTPException(status_code=422, detail="quantity is required for Pending -> Active")
    obj.status = "Active"
    db.commit()
    db.refresh(obj)
    return obj

@router_trade_listing.patch("/{item_id}/transitions/active-to-sold", response_model=TradeListingRead)
def transition_active_to_sold_trade_listing(item_id: int, db: Session = Depends(get_db)) -> TradeListing:
    from fastapi import HTTPException
    obj = db.query(TradeListing).filter(TradeListing.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TradeListing not found")
    try:
        obj.assert_transition("Sold")
    except ValueError as e:
        raise HTTPException(status_code=409, detail=str(e))
    obj.status = "Sold"
    obj.finalize_auction()  # @after
    db.commit()
    db.refresh(obj)
    return obj

@router_trade_listing.patch("/{item_id}/transitions/active-to-expired", response_model=TradeListingRead)
def transition_active_to_expired_trade_listing(item_id: int, db: Session = Depends(get_db)) -> TradeListing:
    from fastapi import HTTPException
    obj = db.query(TradeListing).filter(TradeListing.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TradeListing not found")
    try:
        obj.assert_transition("Expired")
    except ValueError as e:
        raise HTTPException(status_code=409, detail=str(e))
    obj.status = "Expired"
    obj.close()  # @after
    db.commit()
    db.refresh(obj)
    return obj

@router_trade_listing.patch("/{item_id}/transitions/active-to-cancelled", response_model=TradeListingRead)
def transition_active_to_cancelled_trade_listing(item_id: int, db: Session = Depends(get_db), current_user=Depends(get_current_user)) -> TradeListing:
    from fastapi import HTTPException
    obj = db.query(TradeListing).filter(TradeListing.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TradeListing not found")
    if getattr(current_user, "role", None) not in ["Seller", "Admin"]:
        raise HTTPException(status_code=403, detail="Insufficient role for transition Active -> Cancelled")
    try:
        obj.assert_transition("Cancelled")
    except ValueError as e:
        raise HTTPException(status_code=409, detail=str(e))
    obj.status = "Cancelled"
    obj.cancel()  # @after
    db.commit()
    db.refresh(obj)
    return obj

@router_trade_listing.patch("/{item_id}/transitions/sold-to-active", response_model=TradeListingRead)
def transition_sold_to_active_trade_listing(item_id: int, db: Session = Depends(get_db)) -> TradeListing:
    from fastapi import HTTPException
    obj = db.query(TradeListing).filter(TradeListing.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TradeListing not found")
    raise HTTPException(status_code=409, detail="Transition Sold -> Active is not allowed")

@router_trade_listing.patch("/{item_id}/transitions/expired-to-active", response_model=TradeListingRead)
def transition_expired_to_active_trade_listing(item_id: int, db: Session = Depends(get_db)) -> TradeListing:
    from fastapi import HTTPException
    obj = db.query(TradeListing).filter(TradeListing.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TradeListing not found")
    raise HTTPException(status_code=409, detail="Transition Expired -> Active is not allowed")

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

@router_trade_transaction.get("/{item_id}", response_model=TradeTransactionRead)
def get_trade_transaction(item_id: int, db: Session = Depends(get_db)) -> TradeTransaction:
    obj = db.query(TradeTransaction).filter(TradeTransaction.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TradeTransaction not found")
    return obj

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

@router_card_price_history.get("/{item_id}", response_model=CardPriceHistoryRead)
def get_card_price_history(item_id: int, db: Session = Depends(get_db)) -> CardPriceHistory:
    obj = db.query(CardPriceHistory).filter(CardPriceHistory.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="CardPriceHistory not found")
    return obj

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

@router_trade_dispute.patch("/{item_id}/transitions/open-to-underreview", response_model=TradeDisputeRead)
def transition_open_to_under_review_trade_dispute(item_id: int, db: Session = Depends(get_db), current_user=Depends(get_current_user)) -> TradeDispute:
    from fastapi import HTTPException
    obj = db.query(TradeDispute).filter(TradeDispute.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TradeDispute not found")
    if getattr(current_user, "role", None) not in ["Admin", "Moderator"]:
        raise HTTPException(status_code=403, detail="Insufficient role for transition Open -> UnderReview")
    try:
        obj.assert_transition("UnderReview")
    except ValueError as e:
        raise HTTPException(status_code=409, detail=str(e))
    obj.status = "UnderReview"
    obj.review()  # @after
    db.commit()
    db.refresh(obj)
    return obj

@router_trade_dispute.patch("/{item_id}/transitions/underreview-to-resolved", response_model=TradeDisputeRead)
def transition_under_review_to_resolved_trade_dispute(item_id: int, db: Session = Depends(get_db), current_user=Depends(get_current_user)) -> TradeDispute:
    from fastapi import HTTPException
    obj = db.query(TradeDispute).filter(TradeDispute.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TradeDispute not found")
    if getattr(current_user, "role", None) not in ["Admin", "Moderator"]:
        raise HTTPException(status_code=403, detail="Insufficient role for transition UnderReview -> Resolved")
    try:
        obj.assert_transition("Resolved")
    except ValueError as e:
        raise HTTPException(status_code=409, detail=str(e))
    if obj.resolution is None:
        raise HTTPException(status_code=422, detail="resolution is required for UnderReview -> Resolved")
    obj.status = "Resolved"
    obj.close_resolved()  # @after
    db.commit()
    db.refresh(obj)
    return obj

@router_trade_dispute.patch("/{item_id}/transitions/underreview-to-escalated", response_model=TradeDisputeRead)
def transition_under_review_to_escalated_trade_dispute(item_id: int, db: Session = Depends(get_db), current_user=Depends(get_current_user)) -> TradeDispute:
    from fastapi import HTTPException
    obj = db.query(TradeDispute).filter(TradeDispute.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TradeDispute not found")
    if getattr(current_user, "role", None) not in ["Admin"]:
        raise HTTPException(status_code=403, detail="Insufficient role for transition UnderReview -> Escalated")
    try:
        obj.assert_transition("Escalated")
    except ValueError as e:
        raise HTTPException(status_code=409, detail=str(e))
    obj.status = "Escalated"
    obj.escalate()  # @after
    db.commit()
    db.refresh(obj)
    return obj

@router_trade_dispute.patch("/{item_id}/transitions/escalated-to-resolved", response_model=TradeDisputeRead)
def transition_escalated_to_resolved_trade_dispute(item_id: int, db: Session = Depends(get_db), current_user=Depends(get_current_user)) -> TradeDispute:
    from fastapi import HTTPException
    obj = db.query(TradeDispute).filter(TradeDispute.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TradeDispute not found")
    if getattr(current_user, "role", None) not in ["Admin"]:
        raise HTTPException(status_code=403, detail="Insufficient role for transition Escalated -> Resolved")
    try:
        obj.assert_transition("Resolved")
    except ValueError as e:
        raise HTTPException(status_code=409, detail=str(e))
    if obj.resolution is None:
        raise HTTPException(status_code=422, detail="resolution is required for Escalated -> Resolved")
    obj.status = "Resolved"
    obj.close_resolved()  # @after
    db.commit()
    db.refresh(obj)
    return obj

@router_trade_dispute.patch("/{item_id}/transitions/resolved-to-open", response_model=TradeDisputeRead)
def transition_resolved_to_open_trade_dispute(item_id: int, db: Session = Depends(get_db)) -> TradeDispute:
    from fastapi import HTTPException
    obj = db.query(TradeDispute).filter(TradeDispute.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TradeDispute not found")
    raise HTTPException(status_code=409, detail="Transition Resolved -> Open is not allowed")

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

@router_trade_dispute.post("/{item_id}/api/disputes/{id}/close", status_code=status.HTTP_204_NO_CONTENT)
def close_resolved_trade_dispute(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(TradeDispute).filter(TradeDispute.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TradeDispute not found")
    obj.close_resolved()
    db.commit()

@router_trade_dispute.post("/{item_id}/api/disputes/{id}/review", status_code=status.HTTP_204_NO_CONTENT)
def review_trade_dispute(item_id: int, db: Session = Depends(get_db)):
    obj = db.query(TradeDispute).filter(TradeDispute.id == item_id).first()
    if obj is None:
        raise HTTPException(status_code=404, detail="TradeDispute not found")
    obj.review()
    db.commit()
