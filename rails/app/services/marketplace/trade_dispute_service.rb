module Marketplace
  class TradeDisputeService
    def initialize(repository = TradeDispute)
      @repository = repository
    end

    def create(attributes)
      raise NotImplementedError, "#{self.class}#create not implemented"
    end

    def update(entity, attributes)
      raise NotImplementedError, "#{self.class}#update not implemented"
    end

    def escalate(id)
      instance = TradeDispute.find(id)
      instance.escalate()
      instance.save!
    end

    def resolve(id, resolution_text)
      instance = TradeDispute.find(id)
      instance.resolve(resolution_text)
      instance.save!
    end

    def review(id)
      instance = TradeDispute.find(id)
      instance.review()
      instance.save!
    end
  end
end
