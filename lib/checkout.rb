class Checkout
  def initialize(pricing_rules)
    @pricing_rules = pricing_rules
    @cart_items = []
  end

  def scan
    # TO-DO
  end

  def total
    # TO-DO
  end

  private

  attr_reader :pricing_rules, :cart_items
end