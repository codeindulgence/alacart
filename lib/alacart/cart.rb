module Alacart
  class Cart
    attr_reader :inventory, :items

    def initialize(inventory, modifiers = [])
      @inventory = inventory
      @modifiers = create_modifier_procs(modifiers)
      @items = []
    end

    def add_modifier(modifier)
      @modifiers.merge! create_modifier_procs([modifier])
    end

    def add(sku)
      @items << sku if @inventory.include? sku
    end

    def include?(sku)
      @items.include? sku
    end

    def empty!
      @items = []
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

    def create_multibuy_modifier(sku, count)
      amount = @inventory[sku]
      mod_sku = '%s_%s_%s' % [sku, 'multibuy', count]
      @inventory[mod_sku] = amount * -1
      proc {|items| [mod_sku] * (items.count{|i|i==sku}/count)}
    end

    def create_bulk_modifier(sku, count, discount)
      mod_sku = '%s_%s_%s_%s' % [sku, 'bulk', count, discount]
      @inventory[mod_sku] = -1 * discount
      proc do |items|
        num_skus = items.count{|i|i==sku}
        [mod_sku] * num_skus if num_skus > count
      end
    end

    def create_freebie_modifier(sku, companion)
      mod_sku = '%s_%s_%s' % [sku, 'freebie', companion]
      @inventory[mod_sku] = -1 * @inventory[companion]
      proc do |items|
        count = [items.count{|i|i==sku}, items.count{|i|i==companion}].min
        [mod_sku] * count
      end
    end

  end
end
