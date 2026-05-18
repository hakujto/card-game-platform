module Marketplace
  class TradeBidService
    def initialize(repository = TradeBid)
      @repository = repository
    end

    def create(attributes)
      raise NotImplementedError, "#{self.class}#create not implemented"
    end

    def update(entity, attributes)
      raise NotImplementedError, "#{self.class}#update not implemented"
    end

    def outbid_by(id)
      instance = TradeBid.find(id)
      result = instance.outbid_by(new_amount)
      instance.save!
      result
    end

    def retract(id)
      instance = TradeBid.find(id)
      instance.retract()
      instance.save!
    end
  end
end
