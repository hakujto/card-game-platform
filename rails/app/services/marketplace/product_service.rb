module Marketplace
  class ProductService
    def initialize(repository = Product)
      @repository = repository
    end

    def create(attributes)
      raise NotImplementedError, "#{self.class}#create not implemented"
    end

    def update(entity, attributes)
      raise NotImplementedError, "#{self.class}#update not implemented"
    end

    def activate(id)
      instance = Product.find(id)
      instance.activate()
      instance.save!
    end

    def deactivate(id)
      instance = Product.find(id)
      instance.deactivate()
      instance.save!
    end

    def apply_discount(id, percent)
      instance = Product.find(id)
      result = instance.apply_discount(percent)
      instance.save!
      result
    end

    def restock(id, quantity)
      instance = Product.find(id)
      instance.restock(quantity)
      instance.save!
    end
  end
end
