module Marketplace
  class OrderItemService
    def initialize(repository = OrderItem)
      @repository = repository
    end

    def create(attributes)
      raise NotImplementedError, "#{self.class}#create not implemented"
    end

    def update(entity, attributes)
      raise NotImplementedError, "#{self.class}#update not implemented"
    end

    def line_total(id)
      instance = OrderItem.find(id)
      result = instance.line_total()
      instance.save!
      result
    end
  end
end
