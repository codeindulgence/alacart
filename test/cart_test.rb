require_relative 'test_helper.rb'

class CartTest < Minitest::Test
  def setup
    @inventory = {
      'sku1' =>  100,
      'sku2' =>  20,
      'sku3' =>  3.45
    }
    @cart = Alacart::Cart.new @inventory
  end

  def test_initializing_cart_inventory
    assert_equal @cart.inventory, {
      'sku1' => 100,
      'sku2' => 20,
      'sku3' => 3.45
    }
  end

  def test_adding_items
    assert @cart.add('sku1')
    assert @cart.include? 'sku1'
  end

  def test_adding_invalid_items
    assert !@cart.add('invalid')
    assert !@cart.include?('invalid')
  end

  def test_cart_empty
    @cart.add 'sku1'
    @cart.empty!
    assert @cart.items.empty?
  end

  def test_cart_total
    @cart.add 'sku1'
    @cart.add 'sku2'
    @cart.add 'sku3'
    assert_equal 123.45, @cart.total
  end

  def test_multibuy
    # Three for Two
    @cart.add_modifier sku: 'sku1', type: :multibuy, params: [3]
    3.times { @cart.add 'sku1' }
    assert_equal ['sku1_multibuy_3'], @cart.discounts
    assert_equal 200, @cart.total

    # 6 for 4 on 3 for 2
    3.times { @cart.add 'sku1' }
    assert_equal ['sku1_multibuy_3'] * 2, @cart.discounts
    assert_equal 400, @cart.total

    # BOGOF
    setup
    @cart.add_modifier sku: 'sku1', type: :multibuy, params: [2]
    2.times { @cart.add 'sku1' }
    assert_equal ['sku1_multibuy_2'], @cart.discounts
    assert_equal 100, @cart.total

    # Doesn't happen when not enough
    setup
    @cart.add_modifier sku: 'sku1', type: :multibuy, params: [5]
    4.times { @cart.add 'sku1' }
    assert_equal [], @cart.discounts
    assert_equal 400, @cart.total
  end

  def test_bulk_discount
    @cart.add_modifier sku: 'sku1', type: :bulk, params: [4, 50]
    # Nothing off for 4
    4.times { @cart.add 'sku1' }
    assert_equal [], @cart.discounts
    assert_equal 400, @cart.total

    # $50 off for more than 4
    @cart.add 'sku1'
    assert_equal ['sku1_bulk_4_50'] * 5, @cart.discounts
    assert_equal 250, @cart.total
  end

  def test_freebie
    @cart.add_modifier sku: 'sku1', type: :freebie, params: ['sku2']
    # No freebie for just target SKU
    @cart.add 'sku1'
    assert_equal [], @cart.discounts
    assert_equal 100, @cart.total

    # Companion item gets discounted
    @cart.add 'sku2'
    assert_equal ['sku1_freebie_sku2'], @cart.discounts
    assert_equal 100, @cart.total

    # Additional companion does not
    @cart.add 'sku2'
    assert_equal ['sku1_freebie_sku2'], @cart.discounts
    assert_equal 120, @cart.total
  end

  def test_mixed_modifiers
    inventory = {
      'ipd' => 549.99,
      'mbp' => 1399.99,
      'atv' => 109.50,
      'vga' => 30.00
    }
    modifiers = [
      {sku: 'atv', type: :multibuy, params: [3]},
      {sku: 'ipd', type: :bulk, params: [4, 50]},
      {sku: 'mbp', type: :freebie, params: ['vga']}
    ]
    cart = Alacart::Cart.new(inventory, modifiers)

    # SKUs Scanned: atv, atv, atv, vga Total expected: $249.00
    3.times { cart.add 'atv' }
    cart.add 'vga'
    assert_equal 249.00, cart.total
    cart.empty!

    # SKUs Scanned: atv, ipd, ipd, atv, ipd, ipd, ipd Total expected: $2718.95
    cart.add 'atv'
    cart.add 'ipd'
    cart.add 'ipd'
    cart.add 'atv'
    cart.add 'ipd'
    cart.add 'ipd'
    cart.add 'ipd'
    assert_equal 2718.95, cart.total
    cart.empty!

    # SKUs Scanned: mbp, vga, ipd Total expected: $1949.98
    cart.add 'mbp'
    cart.add 'vga'
    cart.add 'ipd'
    assert_equal 1949.98, cart.total
  end

end
