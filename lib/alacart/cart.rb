module Alacart
  class Cart
    attr_reader :inventory

    def initialize(inventory)
      @inventory = inventory
      @skus = inventory.keys.map(&:to_s)
    end

    def add(sku)
      @skus.include? sku
    end
  end
end
