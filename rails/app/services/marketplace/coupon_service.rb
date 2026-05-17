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
