module PricingRules
  # This rule enforces a fixed "two-thirds of base price" calculation once the
  # minimum quantity threshold is met.
  #
  # It compares the current unit_price (after earlier rules) to the exact
  # two-thirds calculation and applies whichever is cheaper:
  #
  # This guarantees that:
  # - Never charge more than two-thirds of the base price when the quantity
  #   threshold is reached.
  # - If an earlier rule already made the item even cheaper, that price is preserved.
  #
  # Example:
  # - Base price: £11.23 → two-thirds price: £7.49
  # - Current price after other rules: £8.00 → result: £7.49 (cheaper price wins)
  # - Current price after other rules: £6.50 → result: £6.50 (no increase applied)
  #
  # This approach makes the two-thirds rule stack safely with other promotions
  # while guaranteeing you never exceed the intended discounted price.
  class TwoThirdsRule < ::PricingRule
    def apply(cart_items)
      item = cart_items.find { |ci| ci.code == options["product_code"] }
      return unless item

      if item.quantity >= options["min_quantity"]
        item.unit_price = [
          item.unit_price,                                    # current price (after earlier rules)
          item.unit_price = item.base_price * Rational(2, 3)  # discounted base price
        ].min
      end
    end
  end
end