module Cards
  class CardService
    def initialize(repository = Card)
      @repository = repository
    end

    def create(attributes)
      raise NotImplementedError, "#{self.class}#create not implemented"
    end

    def update(entity, attributes)
      raise NotImplementedError, "#{self.class}#update not implemented"
    end

    def ban(id)
      instance = Card.find(id)
      instance.ban()
      instance.save!
    end

    def unban(id)
      instance = Card.find(id)
      instance.unban()
      instance.save!
    end

    def restrict(id)
      instance = Card.find(id)
      instance.restrict()
      instance.save!
    end

    def unrestrict(id)
      instance = Card.find(id)
      instance.unrestrict()
      instance.save!
    end

    def calculate_value(id)
      instance = Card.find(id)
      result = instance.calculate_value()
      instance.save!
      result
    end

    def apply_rarity_bonus(id, multiplier)
      instance = Card.find(id)
      result = instance.apply_rarity_bonus(multiplier)
      instance.save!
      result
    end

    def is_legal_in_format(id)
      instance = Card.find(id)
      result = instance.is_legal_in_format(format)
      instance.save!
      result
    end
  end
end
