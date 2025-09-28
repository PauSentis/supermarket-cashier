require "spec_helper"

RSpec.describe PricingRules::BulkDiscountRule do
  let(:product) { Product.new("SR1", "Strawberries", 5.00) }
  let(:cart_item) { CartItem.new(product) }
  let(:rule) { described_class.new("type" => "BulkDiscountRule", "product_code" => "SR1", "min_quantity" => 3, "new_price" => 4.50) }

  describe "#apply" do
    it "does nothing if no matching item" do
      cart_item = CartItem.new(Product.new("GR1", "Green Tea", 3.11))
      expect { rule.apply([cart_item]) }.not_to change { cart_item.unit_price }
    end

    it "does nothing if quantity is below min_quantity" do
      cart_item.increment # quantity = 2
      expect { rule.apply([cart_item]) }.not_to change { cart_item.unit_price }
    end

    it "applies discount for quantity at min_quantity" do
      2.times { cart_item.increment } # quantity = 3
      rule.apply([cart_item])
      expect(cart_item.unit_price).to eq(4.50)
    end

    it "applies discount for quantity above min_quantity" do
      3.times { cart_item.increment } # quantity = 4
      rule.apply([cart_item])
      expect(cart_item.unit_price).to eq(4.50)
    end

    it "preserves lower price from previous rules" do
      2.times { cart_item.increment } # quantity = 3
      cart_item.unit_price = 4.00 # Lower than 4.50
      rule.apply([cart_item])
      expect(cart_item.unit_price).to eq(4.00)
    end
  end
end