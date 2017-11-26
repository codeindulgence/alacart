module Alacart
  class Cart
    attr_reader :inventory, :items

    # Initialize the cart with an inventory and modifiers
    # The inventory is a hash of SKUs to price
    # The modifiers is an array of modifier descriptions
    #
    # Modifiers are hashes with keys:
    #   sku: The item which the modifier applies to
    #   type: One of the built in modifier types
    #   params: Array of params to configure modifyer, based on type
    #
    # Adding a modifier will create a new SKU with a (typically) negative
    # value). When an eligible discount is identified, it's SKU is simply added
    # to the cart
    #
    # Modifier Types:
    #   multibuy(count):
    #     Discount the entire value of 1 in every <count> for the given SKU
    #   bulk(count, discount):
    #     Discount <n>*<discount> when the count of the given SKU exceeds
    #     <count> where <n> is the count added
    #   freebie(companion):
    #     Discount the value of the <companion> SKU when both it and the given
    #     SKU have been added
    def initialize(inventory, modifiers = [])
      @inventory = inventory
      @modifiers = create_modifier_procs(modifiers)
      @items = []
    end

    # Add a new SKU to the inventory
    def add_sku(sku, amount)
      @inventory[sku] = amount
    end

    # Add a modifier after initialization
    def add_modifier(modifier)
      @modifiers.merge! create_modifier_procs([modifier])
    end

    # Add an SKU. Invalid values will return false
    def add(sku)
      @items << sku if @inventory.include? sku
    end

    # Checks if the cart contains the given SKU
    def include?(sku)
      @items.include? sku
    end

    # Remove all items from the cart
    def empty!
      @items = []
    end

    # Return the list of discount SKU that the cart is eligible for
    def discounts
      @items.uniq.map do |sku|
        (@modifiers[sku] || []).map do |modifier|
          modifier.call @items
        end
      end.flatten
    end

    # Tally up the total cart value of items and any discounts
    def total
      (@items + discounts).map do |item|
        inventory[item]
      end.reduce(:+)
    end

    private

    # Given an array of modifiers, return a hash of proc objects grouped by
    # SKU. A modifier proc takes the array of cart items as it's only parameter
    # and returns an array of the modifier SKU of length determing by the proc
    # logic.
    def create_modifier_procs(modifiers)
      modifiers.inject({}) do |memo,mod|
        sku = mod[:sku]
        memo[sku] ||= []
        method = "create_#{mod[:type]}_modifier"
        memo[sku] << send(method, sku, *mod[:params])
        memo
      end
    end

    # Built in modifier types. Each method returns a proc for the given SKU and
    # params and adds it's own SKU record into the @inventory

    def create_multibuy_modifier(sku, count)
      # SKU to deduct value of <sku>
      mod_sku = '%s_%s_%s' % [sku, 'multibuy', count]
      add_sku mod_sku, @inventory[sku] * -1

      proc do |items|
        num_present = items.count(sku)
        [mod_sku] * (num_present/count)
      end
    end

    def create_bulk_modifier(sku, count, discount)
      # SKU to deduct <discount>
      mod_sku = '%s_%s_%s_%s' % [sku, 'bulk', count, discount]
      add_sku mod_sku, -1 * discount

      proc do |items|
        num_present = items.count(sku)
        num_present > count ? [mod_sku] * num_present : []
      end
    end

    def create_freebie_modifier(sku, companion)
      # SKU to deduct value of <companion> SKU
      mod_sku = '%s_%s_%s' % [sku, 'freebie', companion]
      add_sku mod_sku, -1 * @inventory[companion]

      proc do |items|
        count = [items.count(sku), items.count(companion)].min
        [mod_sku] * count
      end
    end

  end
end
