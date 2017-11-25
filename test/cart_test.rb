require_relative 'test_helper.rb'

class CartTest < Minitest::Test

  def setup
    @inventory = {
      sku1: 100,
      sku2: 20,
      sku3: 3.45
    }
  end

  def test_initializing_cart_inventory
    cart = Alacart::Cart.new @inventory
    assert_equal cart.inventory, @inventory
  end

end
