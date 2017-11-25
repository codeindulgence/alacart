# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'alacart/version'

Gem::Specification.new do |spec|
  spec.name          = "alacart"
  spec.version       = Alacart::VERSION
  spec.authors       = ["Nick Butler"]
  spec.email         = ["nick@codeindulgence.com"]

  spec.summary       = "Super simple shopping cart interface"
  spec.homepage      = "https://github.com/codeindulgence/fabricate"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]
end

