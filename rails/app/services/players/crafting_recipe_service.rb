module Players
  class CraftingRecipeService
    def initialize(repository = CraftingRecipe)
      @repository = repository
    end

    def create(attributes)
      raise NotImplementedError, "#{self.class}#create not implemented"
    end

    def update(entity, attributes)
      raise NotImplementedError, "#{self.class}#update not implemented"
    end

    def can_craft(id)
      instance = CraftingRecipe.find(id)
      result = instance.can_craft(player_id)
      instance.save!
      result
    end

    def execute_craft(id, player_id)
      instance = CraftingRecipe.find(id)
      instance.execute_craft(player_id)
      instance.save!
    end

    def disable(id)
      instance = CraftingRecipe.find(id)
      instance.disable()
      instance.save!
    end

    def enable(id)
      instance = CraftingRecipe.find(id)
      instance.enable()
      instance.save!
    end
  end
end
