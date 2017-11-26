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
  end

  def test_adding_invalid_items
    assert !@cart.add('invalid')
  end

  def test_cart_total
    @cart.add 'sku1'
    @cart.add 'sku2'
    @cart.add 'sku3'
    assert_equal 123.45, @cart.total
  end

  def test_multibuy
    items = ['sku1'] * 3
    modifier = {sku: 'sku1', type: :multibuy, params: [3]}
    cart = Alacart::Cart.new(@inventory, [modifier])
    items.each {|item| cart.add item }
    assert_equal ['sku1_multibuy_3'], cart.discounts
    assert_equal 200, cart.total
  end

end
