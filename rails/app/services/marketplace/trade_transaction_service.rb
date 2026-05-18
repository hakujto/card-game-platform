module Marketplace
  class TradeTransactionService
    def initialize(repository = TradeTransaction)
      @repository = repository
    end

    def create(attributes)
      raise NotImplementedError, "#{self.class}#create not implemented"
    end

    def update(entity, attributes)
      raise NotImplementedError, "#{self.class}#update not implemented"
    end

    def complete(id)
      instance = TradeTransaction.find(id)
      instance.complete()
      instance.save!
    end

    def refund(id)
      instance = TradeTransaction.find(id)
      instance.refund()
      instance.save!
    end

    def open_dispute(id, reason)
      instance = TradeTransaction.find(id)
      instance.open_dispute(reason)
      instance.save!
    end

    def seller_net(id)
      instance = TradeTransaction.find(id)
      result = instance.seller_net()
      instance.save!
      result
    end
  end
end
