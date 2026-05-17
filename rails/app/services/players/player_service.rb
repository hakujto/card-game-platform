module Players
  class PlayerService
    def initialize(repository = Player)
      @repository = repository
    end

    def create(attributes)
      raise NotImplementedError, "#{self.class}#create not implemented"
    end

    def update(entity, attributes)
      raise NotImplementedError, "#{self.class}#update not implemented"
    end

    def promote(id)
      instance = Player.find(id)
      result = instance.promote()
      instance.save!
      result
    end

    def demote(id)
      instance = Player.find(id)
      result = instance.demote()
      instance.save!
      result
    end

    def record_win(id)
      instance = Player.find(id)
      instance.record_win()
      instance.save!
    end

    def record_loss(id)
      instance = Player.find(id)
      instance.record_loss()
      instance.save!
    end

    def win_rate(id)
      instance = Player.find(id)
      result = instance.win_rate()
      instance.save!
      result
    end

    def verify(id)
      instance = Player.find(id)
      instance.verify()
      instance.save!
    end

    def update_rating(id, delta)
      instance = Player.find(id)
      instance.update_rating(delta)
      instance.save!
    end
  end
end
