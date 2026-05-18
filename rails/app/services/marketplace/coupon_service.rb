module Marketplace
  class CouponService
    def initialize(repository = Coupon)
      @repository = repository
    end

    def create(attributes)
      raise NotImplementedError, "#{self.class}#create not implemented"
    end

    def update(entity, attributes)
      raise NotImplementedError, "#{self.class}#update not implemented"
    end

    def is_valid(id)
      instance = Coupon.find(id)
      result = instance.is_valid()
      instance.save!
      result
    end

    def is_applicable_to_order(id)
      instance = Coupon.find(id)
      result = instance.is_applicable_to_order(order_total)
      instance.save!
      result
    end

    def redeem(id)
      instance = Coupon.find(id)
      instance.redeem()
      instance.save!
    end

    def deactivate(id)
      instance = Coupon.find(id)
      instance.deactivate()
      instance.save!
    end
  end
end
