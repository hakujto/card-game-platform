module Cards
  class CardSetService
    def initialize(repository = CardSet)
      @repository = repository
    end

    def create(attributes)
      raise NotImplementedError, "#{self.class}#create not implemented"
    end

    def update(entity, attributes)
      raise NotImplementedError, "#{self.class}#update not implemented"
    end

    def is_legal_in_standard(id)
      instance = CardSet.find(id)
      result = instance.is_legal_in_standard()
      instance.save!
      result
    end

    def is_legal_in_format(id)
      instance = CardSet.find(id)
      result = instance.is_legal_in_format(format)
      instance.save!
      result
    end

    def card_count_by_rarity(id)
      instance = CardSet.find(id)
      result = instance.card_count_by_rarity(rarity)
      instance.save!
      result
    end

    def rotate_out(id)
      instance = CardSet.find(id)
      instance.rotate_out()
      instance.save!
    end
  end
end
