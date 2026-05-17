module Marketplace
  class OrderService
    def initialize(repository = Order)
      @repository = repository
    end

    def create(attributes)
      raise NotImplementedError, "#{self.class}#create not implemented"
    end

    def update(entity, attributes)
      raise NotImplementedError, "#{self.class}#update not implemented"
    end

    def cancel(id)
      instance = Order.find(id)
      instance.cancel()
      instance.save!
    end

    def pay(id, payment_ref)
      instance = Order.find(id)
      result = instance.pay(payment_ref)
      instance.save!
      result
    end

    def calculate_total(id)
      instance = Order.find(id)
      result = instance.calculate_total()
      instance.save!
      result
    end

    def apply_discount(id, percent)
      instance = Order.find(id)
      result = instance.apply_discount(percent)
      instance.save!
      result
    end

    def refund(id)
      instance = Order.find(id)
      instance.refund()
      instance.save!
    end

    # triggered by @on(status = Shipped)
    def set_status(id, value)
      instance = Order.find(id)
      instance.status = value
      if value.to_s.upcase == 'SHIPPED'
        instance.notify_shipped
      end
      instance.save!
    end
  end
end
