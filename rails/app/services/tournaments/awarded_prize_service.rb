module Tournaments
  class AwardedPrizeService
    def initialize(repository = AwardedPrize)
      @repository = repository
    end

    def create(attributes)
      raise NotImplementedError, "#{self.class}#create not implemented"
    end

    def update(entity, attributes)
      raise NotImplementedError, "#{self.class}#update not implemented"
    end

    def claim(id)
      instance = AwardedPrize.find(id)
      instance.claim()
      instance.save!
    end

    # triggered by @on(claimed = true)
    def set_claimed(id, value)
      instance = AwardedPrize.find(id)
      instance.claimed = value
      if value.to_s.upcase == 'TRUE'
        instance.claim
      end
      instance.save!
    end
  end
end
