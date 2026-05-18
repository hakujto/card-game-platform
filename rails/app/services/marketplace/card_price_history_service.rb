module Marketplace
  class CardPriceHistoryService
    def initialize(repository = CardPriceHistory)
      @repository = repository
    end

    def create(attributes)
      raise NotImplementedError, "#{self.class}#create not implemented"
    end

    def update(entity, attributes)
      raise NotImplementedError, "#{self.class}#update not implemented"
    end

    def price_change_percent(id)
      instance = CardPriceHistory.find(id)
      result = instance.price_change_percent(previous_avg)
      instance.save!
      result
    end

    def is_price_spike(id)
      instance = CardPriceHistory.find(id)
      result = instance.is_price_spike(threshold_percent)
      instance.save!
      result
    end
  end
end
