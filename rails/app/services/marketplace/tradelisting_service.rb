module Marketplace
  class TradelistingService
    def initialize(repository = Tradelisting)
      @repository = repository
    end

    def create(attributes)
      raise NotImplementedError, "#{self.class}#create not implemented"
    end

    def update(entity, attributes)
      raise NotImplementedError, "#{self.class}#update not implemented"
    end

    def close(id)
      instance = Tradelisting.find(id)
      instance.close()
      instance.save!
    end

    def extend(id, days)
      instance = Tradelisting.find(id)
      instance.extend(days)
      instance.save!
    end

    def cancel(id)
      instance = Tradelisting.find(id)
      instance.cancel()
      instance.save!
    end

    # triggered by @on(status = Sold)
    def set_status(id, value)
      instance = Tradelisting.find(id)
      instance.status = value
      if value.to_s.upcase == 'SOLD'
        instance.finalize_auction
      end
      instance.save!
    end
  end
end
