module Alacart
  class Cart
    attr_reader :inventory

    def initialize(inventory)
      # Make sure all keys are strings
      @inventory = Hash[inventory.map{|k,v| [k.to_s, v]}]

      @items = Array.new
    end

    def add(sku)
      sku = sku.to_s
      @items << sku
      @inventory.include? sku
    end

    def total
      @items.map do |item|
        inventory[item]
      end.reduce(:+)
    end
  end
end
