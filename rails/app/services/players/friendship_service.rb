module Players
  class FriendshipService
    def initialize(repository = Friendship)
      @repository = repository
    end

    def create(attributes)
      raise NotImplementedError, "#{self.class}#create not implemented"
    end

    def update(entity, attributes)
      raise NotImplementedError, "#{self.class}#update not implemented"
    end

    def accept(id)
      instance = Friendship.find(id)
      instance.accept()
      instance.save!
    end

    def decline(id)
      instance = Friendship.find(id)
      instance.decline()
      instance.save!
    end

    def block(id)
      instance = Friendship.find(id)
      instance.block()
      instance.save!
    end
  end
end
