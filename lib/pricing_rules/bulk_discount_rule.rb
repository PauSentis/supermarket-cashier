# frozen_string_literal: true

module PricingRules
  # This rule applies a bulk price reduction when the quantity threshold is met,
  # but does so in a way that respects prior discounts.
  #
  # Instead of always forcing the unit_price to the bulk price, it takes the
  # lower of the current unit_price and the configured bulk price:
  #
  # This ensures that:
  # - If a previous rule already lowered the price below the bulk price,
  #   that better price is preserved.
  # - If no discounts have been applied (or price is still higher),
  #   the bulk discount takes effect and lowers the price.
  #
  # Example:
  # - Base price: £5.00
  # - Bulk price: £4.50
  # - Previous discount: £4.00
  # Result: unit_price stays at £4.00 (cheaper than bulk price).
  #
  # This approach allows bulk discounts to stack safely with other rules
  # without accidentally overriding a better price.
  class BulkDiscountRule < ::PricingRule
    def apply(cart_items)
      item = cart_items.find { |ci| ci.code == options['product_code'] }
      return unless item

      return unless item.quantity >= options['min_quantity']

      item.unit_price = [item.unit_price, options['new_price']].min
    end
  end
end
