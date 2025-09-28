require "spec_helper"

RSpec.describe PricingRules::BogoRule do
  let(:product) { Product.new("GR1", "Green Tea", 3.11) }
  let(:cart_item) { CartItem.new(product) }
  let(:rule) { described_class.new("type" => "BogoRule", "product_code" => "GR1") }

  describe "#apply" do
    it "does nothing if no matching item" do
      cart_item = CartItem.new(Product.new("SR1", "Strawberries", 5.00))
      expect { rule.apply([cart_item]) }.not_to change { cart_item.unit_price }
    end

    it "does nothing if quantity is 1" do
      expect { rule.apply([cart_item]) }.not_to change { cart_item.unit_price }
    end

    it "applies BOGO for quantity 2 (charges for 1)" do
      cart_item.increment # quantity = 2
      rule.apply([cart_item])
      expect(cart_item.unit_price).to eq((3.11 * 1 / 2))
    end

    it "applies BOGO for quantity 3 (charges for 2)" do
      2.times { cart_item.increment } # quantity = 3
      rule.apply([cart_item])
      expect(cart_item.unit_price).to eq((3.11 * 2 / 3))
    end

    it "preserves lower price from previous rules" do
      cart_item.increment # quantity = 2
      cart_item.unit_price = 1.00 # Lower than BOGO price (1.555)
      rule.apply([cart_item])
      expect(cart_item.unit_price).to eq(1.00) # Keeps lower price
    end
  end
end