require_relative 'test_helper.rb'

class CartTest < Minitest::Test

  def setup
    @inventory = {
      sku1: 100,
      sku2: 20,
      sku3: 3.45
    }
    @cart = Alacart::Cart.new @inventory
  end

  def test_initializing_cart_inventory
    assert_equal @cart.inventory, @inventory
  end

  def test_adding_items
    assert @cart.add('sku1')
  end

end
