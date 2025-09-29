# frozen_string_literal: true

require_relative 'product'
require_relative 'cart_item'
require_relative 'pricing_rule'

class Checkout
  attr_reader :total, :cart_items, :pricing_rules

  def initialize(pricing_rules = PricingRule.all)
    @pricing_rules = pricing_rules
    @cart_items = []
    @total = 0.0
  end

  # Add a product to the cart
  def scan(code)
    product = Product.find_by_code(code)
    return false unless product

    item = cart_items.find { |ci| ci.code == code }
    if item
      item.increment
    else
      cart_items << ::CartItem.new(product)
    end

    recaulate_total
  end

  private

  def recaulate_total
    reset_prices
    apply_rules
    @total = cart_items.sum(&:total_amount).round(2)
  end

  # Reset all unit prices to their base prices before re-applying rules
  def reset_prices
    cart_items.each { |item| item.unit_price = item.base_price }
  end

  def apply_rules
    pricing_rules.each { |rule| rule.apply(cart_items) }
  end
end
