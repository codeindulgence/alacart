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
    @cart.add 'sku1'
    @cart.add 'sku2'
    assert_equal ['sku1_freebie_sku2'], @cart.discounts
    assert_equal 100, @cart.total
  end

end
