# frozen_string_literal: true

module PricingRules
  # This rule applies a "Buy One, Get One Free" (BOGO) offer by recalculating
  # the unit price so that effectively half of the items are free.
  #
  # It compares the calculated BOGO price with the current unit_price (after
  # any previous discounts) and applies whichever is cheaper:
  #
  # This guarantees:
  # - If no previous discounts exist, BOGO is applied as usual.
  # - If a previous rule already made the item cheaper than the BOGO price,
  #   that cheaper price is preserved (no price increases ever occur).
  #
  # Example:
  # - Base price: £3.11, quantity: 3 → effective_quantity: 2
  # - BOGO price: (3.11 * 2 / 3) ≈ £2.07 per item
  # - Current price after other rules: £1.80 → final price remains £1.80
  class BogoRule < ::PricingRule
    def apply(cart_items)
      item = cart_items.find { |ci| ci.code == options['product_code'] }
      return unless item

      free_count = item.quantity / 2
      return if free_count.zero?

      effective_quantity = item.quantity - free_count
      bogo_price = (item.base_price * effective_quantity / item.quantity)
      item.unit_price = [item.unit_price, bogo_price].min
    end
  end
end
