module Alacart
  class Cart
    attr_reader :inventory

    def initialize(inventory, modifiers = [])
      @inventory = inventory
      @modifiers = create_modifier_procs(modifiers)
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
      value = opts.first
      amount = @inventory[sku]
      mod_sku = '%s_%s_%s' % [sku, 'multibuy', value]
      @inventory[mod_sku] = amount * -1
      proc {|items| [mod_sku] * (items.count{|i|i==sku}/value)}
    end
  end
end
