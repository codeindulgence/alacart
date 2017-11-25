Alacart
=======
Super simple shopping cart interface

Installation
------------
Build it:  
`gem build alacart.gemspec`


Install it:  
`gem install alacart*.gem`

Usage
-----

```
require 'alacart'

inventory = {
  sku1: 100,
  sku2: 20,
  sku3: 3.45
}

cart = Alacart::Cart.new(inventory)
cart.add 'sku1' # True
cart.add 'sku2' # True
cart.add 'sku3' # True
cart.total # 123.45
```
