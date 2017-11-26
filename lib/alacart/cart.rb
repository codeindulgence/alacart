module Alacart
  class Cart
    attr_reader :inventory, :items

    def initialize(inventory, modifiers = [])
      @inventory = inventory
      @modifiers = create_modifier_procs(modifiers)
      @items = Array.new
    end

    def add(sku)
      @items << sku
      @inventory.include? sku
    end

    def discounts
      @items.uniq.map do |sku|
        (@modifiers[sku] || []).map do |modifier|
          modifier.call @items
        end
      end.flatten
    end

    def total
      (@items + discounts).map do |item|
        inventory[item]
      end.reduce(:+)
    end

    private

    def create_modifier_procs(modifiers)
      modifiers.inject({}) do |memo,mod|
        sku = mod[:sku]
        memo[sku] ||= []
        method = "create_#{mod[:type]}_modifier"
        memo[sku] << send(method, sku, *mod[:params])
        memo
      end
    end

    def create_multibuy_modifier(sku, *opts)
      count = opts.first
      amount = @inventory[sku]
      mod_sku = '%s_%s_%s' % [sku, 'multibuy', count]
      @inventory[mod_sku] = amount * -1
      proc {|items| [mod_sku] * (items.count{|i|i==sku}/count)}
    end

    def create_bulk_modifier(sku, *opts)
      count, discount = opts
      mod_sku = '%s_%s_%s_%s' % [sku, 'bulk', count, discount]
      @inventory[mod_sku] = -1 * discount
      proc do |items|
        num_skus = items.count{|i|i==sku}
        [mod_sku] * num_skus if num_skus > count
      end
    end

  end
end
