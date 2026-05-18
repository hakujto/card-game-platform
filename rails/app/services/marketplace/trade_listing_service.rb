module Marketplace
  class TradeListingService
    def initialize(repository = TradeListing)
      @repository = repository
    end

    def create(attributes)
      raise NotImplementedError, "#{self.class}#create not implemented"
    end

    def update(entity, attributes)
      raise NotImplementedError, "#{self.class}#update not implemented"
    end

    def close(id)
      instance = TradeListing.find(id)
      instance.close()
      instance.save!
    end

    def extend(id, days)
      instance = TradeListing.find(id)
      instance.extend(days)
      instance.save!
    end

    def cancel(id)
      instance = TradeListing.find(id)
      instance.cancel()
      instance.save!
    end

    def is_expired(id)
      instance = TradeListing.find(id)
      result = instance.is_expired()
      instance.save!
      result
    end

    def finalize_auction(id)
      instance = TradeListing.find(id)
      instance.finalize_auction()
      instance.save!
    end

    # triggered by @on(status = Sold)
    def set_status(id, value)
      instance = TradeListing.find(id)
      instance.status = value
      if value.to_s.upcase == 'SOLD'
        instance.finalize_auction
      end
      instance.save!
    end
  end
end
