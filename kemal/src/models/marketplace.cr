require "db"
require "json"

class Product
  include DB::Serializable
  include JSON::Serializable

  property id : Int64?
  property created_at : String?
  property updated_at : String?
  property name : String
  property product_type : String = "SingleCard"
  property price : Float64
  property stock : Int32 = 0
  property active : Bool = true
  property discount_percent : Int32 = 0
  property description : String?
  property image_url : String?
  property featured : Bool = false
  property card_id : Int64?
  property card_set_id : Int64?

  def activate()
    # TODO: implement activate
  end

  def deactivate()
    # TODO: implement deactivate
  end

  def apply_discount(percent : Int32) : Float64
    # TODO: implement apply_discount
    0.0
  end

  def restock(quantity : Int32)
    # TODO: implement restock
  end

  def effective_price() : Float64
    # TODO: implement effective_price
    0.0
  end

  def is_in_stock() : Bool
    # TODO: implement is_in_stock
    false
  end

  def validate
    errors = [] of String
    # Rule: Product price must be greater than zero
    errors << "Product price must be greater than zero" if !(price > 0)
    # Rule: Product stock must not be negative
    errors << "Product stock must not be negative" if !(stock >= 0)
    # Rule: Product discount percent must be between 0 and 100
    errors << "Product discount percent must be between 0 and 100" if !((discount_percent >= 0 && discount_percent <= 100))
    errors << "discount_percent must be >= 0" if discount_percent < 0
    errors << "discount_percent must be <= 100" if discount_percent > 100
    errors
  end

end

class Order
  include DB::Serializable
  include JSON::Serializable

  property id : Int64?
  property created_at : String?
  property updated_at : String?
  property status : String = "Pending"
  property total : Float64 = 0.0
  property discount_applied : Float64 = 0.0
  property currency : String = "USD"
  property payment_method : String?
  property payment_reference : String?
  property shipping_address : String?
  property tracking_number : String?
  property paid_at : String?
  property shipped_at : String?
  property player_id : Int64?
  property coupon_id : Int64?
  property created_by : Int64?
  property updated_by : Int64?

  def cancel()
    # TODO: implement cancel
  end

  def pay(payment_ref : String) : Bool
    raise "Guard failed: status == Pending" unless status == Pending
    # TODO: implement pay
    false
  end

  def process_payment() : Bool
    # TODO: implement process_payment
    false
  end

  def calculate_total() : Float64
    # TODO: implement calculate_total
    0.0
  end

  def apply_discount(percent : Int32) : Float64
    # TODO: implement apply_discount
    0.0
  end

  def refund()
    # TODO: implement refund
  end

  def notify_shipped()
    # TODO: implement notify_shipped
  end

  enum OrderStatus
    Pending
    Paid
    Processing
    Shipped
    Completed
    Cancelled
    Refunded
  end

  def transition_to(new_status : String)
    raise "Transition denied" if ["Refunded", "Completed"].includes?(status.to_s)
    # TODO: validate transition
    self.status = new_status
  end

  def validate
    errors = [] of String
    # Rule: Paid order must have paid_at set
    errors << "Paid order must have paid_at set" if !(!(status == Paid) || (paid_at != nil))
    # Rule: Shipped order must have a tracking number
    errors << "Shipped order must have a tracking number" if !(!(status == Shipped) || (tracking_number != nil))
    # Rule: shipped_at_requires_shipped_status
    errors << "shipped_at_requires_shipped_status" if !(!(shipped_at != nil) || (status == Shipped))
    # Rule: Order total must not be negative
    errors << "Order total must not be negative" if !(total >= 0)
    # Rule: Discount applied cannot exceed order total
    errors << "Discount applied cannot exceed order total" if !(discount_applied <= total)
    errors << "currency does not match pattern" unless currency.to_s.match(/[A-Z]{3}/)
    # @required_when: {"type":"eq","field":"status","value":"Shipped"}
    errors << "tracking_number is required" if tracking_number.nil?
    # @required_when: {"type":"eq","field":"status","value":"Paid"}
    errors << "paid_at is required" if paid_at.nil?
    errors
  end

end

class OrderItem
  include DB::Serializable
  include JSON::Serializable

  property id : Int64?
  property created_at : String?
  property updated_at : String?
  property quantity : Int32
  property price_at_purchase : Float64
  property foil : Bool = false
  property order_id : Int64?
  property product_id : Int64?

  def line_total() : Float64
    # TODO: implement line_total
    0.0
  end

  def validate
    errors = [] of String
    # Rule: Order item quantity must be greater than zero
    errors << "Order item quantity must be greater than zero" if !(quantity > 0)
    # Rule: Price at purchase must not be negative
    errors << "Price at purchase must not be negative" if !(price_at_purchase >= 0)
    errors
  end

end

class Coupon
  include DB::Serializable
  include JSON::Serializable

  property id : Int64?
  property created_at : String?
  property updated_at : String?
  property code : String
  property discount_type : String = "Percent"
  property discount_value : Float64
  property min_order_value : Float64 = 0.0
  property max_uses : Int32?
  property uses_count : Int32 = 0
  property valid_from : String
  property valid_until : String
  property is_active : Bool = true

  def is_valid() : Bool
    # TODO: implement is_valid
    false
  end

  def is_applicable_to_order(order_total : Float64) : Bool
    # TODO: implement is_applicable_to_order
    false
  end

  def redeem()
    raise "Guard failed: is_active == true" unless is_active == true
    # TODO: implement redeem
  end

  def deactivate()
    # TODO: implement deactivate
  end

  def validate
    errors = [] of String
    # Rule: Coupon expiry must be after its start date
    errors << "Coupon expiry must be after its start date" if !(valid_until > valid_from)
    # Rule: Discount value must be greater than zero
    errors << "Discount value must be greater than zero" if !(discount_value > 0)
    # Rule: Percent discount must be between 1 and 100
    errors << "Percent discount must be between 1 and 100" if !(!(discount_type == Percent) || ((discount_value >= 1 && discount_value <= 100)))
    # Rule: Coupon uses count cannot exceed max_uses
    errors << "Coupon uses count cannot exceed max_uses" if !(!(max_uses != nil) || (uses_count <= max_uses))
    errors << "discount_value must be >= 0.01" if discount_value < 0.01
    errors
  end

end

class TradeListing
  include DB::Serializable
  include JSON::Serializable

  property id : Int64?
  property created_at : String?
  property updated_at : String?
  property public_id : String
  property status : String = "Active"
  property listing_type : String = "FixedPrice"
  property asking_price : Float64?
  property auction_start_price : Float64?
  property auction_current_bid : Float64?
  property auction_end_time : String?
  property foil : Bool = false
  property condition : String = "Mint"
  property quantity : Int32 = 1
  property description : String?
  property expires_at : String?
  property seller_id : Int64?
  property card_id : Int64?

  def close()
    # TODO: implement close
  end

  def extend(days : Int32)
    # TODO: implement extend
  end

  def cancel()
    raise "Guard failed: status == Active" unless status == Active
    # TODO: implement cancel
  end

  def is_expired() : Bool
    # TODO: implement is_expired
    false
  end

  def finalize_auction()
    # TODO: implement finalize_auction
  end

  enum TradeListingStatus
    Pending
    Active
    Sold
    Expired
    Cancelled
  end

  def transition_to(new_status : String)
    raise "Transition denied" if ["Sold", "Expired"].includes?(status.to_s)
    # TODO: validate transition
    self.status = new_status
  end

  def validate
    errors = [] of String
    # Rule: Fixed price listing must have an asking price
    errors << "Fixed price listing must have an asking price" if !(!(listing_type == FixedPrice) || (asking_price != nil))
    # Rule: Auction listing must have a start price and end time
    errors << "Auction listing must have a start price and end time" if !(!(listing_type == Auction) || (auction_start_price != nil && auction_end_time != nil))
    # Rule: Listing quantity must be between 1 and 9999
    errors << "Listing quantity must be between 1 and 9999" if !((quantity >= 1 && quantity <= 9999))
    # @required_when: {"type":"eq","field":"listing_type","value":"FixedPrice"}
    errors << "asking_price is required" if asking_price.nil?
    errors
  end

end

class TradeBid
  include DB::Serializable
  include JSON::Serializable

  property id : Int64?
  property created_at : String?
  property updated_at : String?
  property amount : Float64
  property placed_at : String
  property is_winning : Bool = false
  property listing_id : Int64?
  property bidder_id : Int64?

  def outbid_by(new_amount : Float64) : Bool
    # TODO: implement outbid_by
    false
  end

  def retract()
    # TODO: implement retract
  end

  def validate
    errors = [] of String
    # Rule: Bid amount must be greater than zero
    errors << "Bid amount must be greater than zero" if !(amount > 0)
    errors
  end

end

class TradeTransaction
  include DB::Serializable
  include JSON::Serializable

  property id : Int64?
  property created_at : String?
  property updated_at : String?
  property final_price : Float64
  property platform_fee : Float64
  property status : String = "Pending"
  property completed_at : String?
  property listing_id : Int64?
  property buyer_id : Int64?
  property seller_id : Int64?
  property created_by : Int64?
  property updated_by : Int64?

  def complete()
    # TODO: implement complete
  end

  def refund()
    # TODO: implement refund
  end

  def open_dispute(reason : String)
    # TODO: implement open_dispute
  end

  def seller_net() : Float64
    # TODO: implement seller_net
    0.0
  end

  def validate
    errors = [] of String
    # Rule: Platform fee cannot exceed the final price
    errors << "Platform fee cannot exceed the final price" if !(platform_fee <= final_price)
    # Rule: Platform fee must not be negative
    errors << "Platform fee must not be negative" if !(platform_fee >= 0)
    # Rule: Transaction final price must be greater than zero
    errors << "Transaction final price must be greater than zero" if !(final_price > 0)
    # Rule: Completed transaction must have a completed_at timestamp
    errors << "Completed transaction must have a completed_at timestamp" if !(!(status == Completed) || (completed_at != nil))
    # @required_when: {"type":"eq","field":"status","value":"Completed"}
    errors << "completed_at is required" if completed_at.nil?
    errors
  end

end

class CardPriceHistory
  include DB::Serializable
  include JSON::Serializable

  property id : Int64?
  property created_at : String?
  property updated_at : String?
  property price_date : String
  property avg_price : Float64
  property min_price : Float64
  property max_price : Float64
  property volume : Int32
  property foil : Bool = false
  property card_id : Int64?

  def price_change_percent(previous_avg : Float64) : Float64
    # TODO: implement price_change_percent
    0.0
  end

  def is_price_spike(threshold_percent : Int32) : Bool
    # TODO: implement is_price_spike
    false
  end

  def validate
    errors = [] of String
    # Rule: min_price <= avg_price <= max_price must hold
    errors << "min_price <= avg_price <= max_price must hold" if !((min_price <= avg_price) && (avg_price <= max_price))
    # Rule: Price history volume must not be negative
    errors << "Price history volume must not be negative" if !(volume >= 0)
    # Rule: Prices must not be negative
    errors << "Prices must not be negative" if !(min_price >= 0)
    errors
  end

end

class TradeDispute
  include DB::Serializable
  include JSON::Serializable

  property id : Int64?
  property created_at : String?
  property updated_at : String?
  property status : String = "Open"
  property reason : String
  property description : String
  property resolution : String?
  property opened_at : String
  property resolved_at : String?
  property transaction_id : Int64?
  property opened_by_id : Int64?
  property resolved_by_id : Int64?

  def escalate()
    # TODO: implement escalate
  end

  def resolve(resolution_text : String)
    # TODO: implement resolve
  end

  def close_resolved()
    # TODO: implement close_resolved
  end

  def review()
    # TODO: implement review
  end

  enum TradeDisputeStatus
    Open
    UnderReview
    Resolved
    Escalated
  end

  def transition_to(new_status : String)
    raise "Transition denied" if ["Resolved"].includes?(status.to_s)
    # TODO: validate transition
    self.status = new_status
  end

  def validate
    errors = [] of String
    # Rule: resolved_at_requires_terminal_status
    errors << "resolved_at_requires_terminal_status" if !(!(resolved_at != nil) || (status == Resolved))
    errors
  end

end
