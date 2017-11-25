module Alacart
  class Cart
    attr_reader :inventory

    def initialize(inventory)
      @inventory = inventory
    end
  end
end
