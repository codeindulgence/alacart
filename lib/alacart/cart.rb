module Alacart
  class Cart
    attr_reader :inventory

    def initialize(inventory)
      @inventory = inventory
    end

    def add(sku)
      true
    end
  end
end
