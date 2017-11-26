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
    modifier = {sku: 'sku1', type: :multibuy, params: [3]}
    cart = Alacart::Cart.new(@inventory, [modifier])
    3.times { cart.add 'sku1' }
    assert_equal ['sku1_multibuy_3'], cart.discounts
    assert_equal 200, cart.total
  end

  def test_bulk_discount
    items = ['sku1'] * 5
    modifier = {sku: 'sku1', type: :bulk, params: [4, 50]}
    cart = Alacart::Cart.new(@inventory, [modifier])
    items.each {|item| cart.add item }
    assert_equal ['sku1_bulk_4_50'] * 5, cart.discounts
    assert_equal 250, cart.total
  end

  def test_freebie
    items = ['sku1', 'sku2']
    modifier = {sku: 'sku1', type: :freebie, params: ['sku2']}
    cart = Alacart::Cart.new(@inventory, [modifier])
    items.each {|item| cart.add item }
    assert_equal ['sku1_freebie_sku2'], cart.discounts
    assert_equal 100, cart.total
  end

end
