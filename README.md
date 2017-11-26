Alacart
=======
Super simple shopping cart interface


Installation
------------
Build & install:

```
gem build alacart.gemspec
gem install alacart*.gem
```


Synopsis
--------

Define your inventory:

```
inventory = {
  'ipd' => 549.99,
  'mbp' => 1399.99,
  'atv' => 109.50,
  'vga' => 30.00
}
```


Define discount modifiers:

```
modifiers = [
  {sku: 'atv', type: :multibuy, params: [3]},
  {sku: 'ipd', type: :bulk, params: [4, 50]},
  {sku: 'mbp', type: :freebie, params: ['vga']}
]
```


Initialise the cart:

```
require 'alacart'

cart = Alacart::Cart.new(inventory, modifiers)

```

Add some items:

```
cart.add 'ipd'
cart.add 'mbp'
cart.add 'atv'
cart.total # 2059.48
```
