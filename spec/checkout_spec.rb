require "spec_helper"

RSpec.describe Checkout do
  # Mock products to avoid dependency on config/products.yml
  let(:products) do
    [
      Product.new("GR1", "Green Tea", 3.11),
      Product.new("SR1", "Strawberries", 5.00),
      Product.new("CF1", "Coffee", 11.23)
    ]
  end

  # Mock pricing rules for tests with rules to avoid dependency on config/pricing_rules.yml
  let(:pricing_rules) do
    [
      PricingRules::BogoRule.new(
        "type" => "BogoRule",
        "product_code" => "GR1"
      ),
      PricingRules::BulkDiscountRule.new(
        "type" => "BulkDiscountRule",
        "product_code" => "SR1",
        "min_quantity" => 3,
        "new_price" => 4.50
      ),
      PricingRules::TwoThirdsRule.new(
        "type" => "TwoThirdsRule",
        "product_code" => "CF1",
        "min_quantity" => 3
      )
    ]
  end

  let(:checkout) { described_class.new(pricing_rules) }

  before do
    allow(Product).to receive(:all).and_return(products)
  end

  describe "#total" do
    context "without pricing rules" do
      let(:pricing_rules) { [] }

      it "returns 0.0 for an empty cart" do
        expect(checkout.total).to eq(0.0)
      end

      it "calculates total for a single GR1" do
        %w[GR1].each { |code| checkout.scan(code) }
        expect(checkout.total).to eq(3.11)
      end

      it "calculates total for GR1, SR1, CF1" do
        %w[GR1 SR1 CF1].each { |code| checkout.scan(code) }
        expect(checkout.total).to eq(19.34) # 3.11 + 5.00 + 11.23
      end

      it "calculates total for GR1, GR1, SR1, SR1, CF1" do
        %w[GR1 GR1 SR1 SR1 CF1].each { |code| checkout.scan(code) }
        expect(checkout.total).to eq(27.45) # (2 * 3.11) + (2 * 5.00) + 11.23
      end
    end

    context "with pricing rules" do
      context "BogoRule for GR1 (buy one get one free)" do
        it "charges for one GR1 when scanning two GR1" do
          %w[GR1 GR1].each { |code| checkout.scan(code) }
          expect(checkout.total).to eq(3.11)
        end

        it "charges for two GR1 when scanning three GR1" do
          %w[GR1 GR1 GR1].each { |code| checkout.scan(code) }
          expect(checkout.total).to eq(6.22) # 2 * 3.11
        end

        it "charges for two GR1 when scanning four GR1" do
          %w[GR1 GR1 GR1 GR1].each { |code| checkout.scan(code) }
          expect(checkout.total).to eq(6.22) # 2 * 3.11
        end
      end

      context "BulkDiscountRule for SR1 (3+ items at 4.50 each)" do
        it "charges full price for two SR1" do
          %w[SR1 SR1].each { |code| checkout.scan(code) }
          expect(checkout.total).to eq(10.00) # 2 * 5.00
        end

        it "applies discount price for three SR1" do
          %w[SR1 SR1 SR1].each { |code| checkout.scan(code) }
          expect(checkout.total).to eq(13.50) # 3 * 4.50
        end

        it "applies discount price for four SR1" do
          %w[SR1 SR1 SR1 SR1].each { |code| checkout.scan(code) }
          expect(checkout.total).to eq(18.00) # 4 * 4.50
        end
      end

      context "TwoThirdsRule for CF1 (3+ items at 2/3 total price)" do
        it "charges full price for two CF1" do
          %w[CF1 CF1].each { |code| checkout.scan(code) }
          expect(checkout.total).to eq(22.46) # 2 * 11.23
        end

        it "applies 2/3 discount for three CF1" do
          %w[CF1 CF1 CF1].each { |code| checkout.scan(code) }
          expect(checkout.total).to eq(22.46) # (3 * 11.23 * 2.0 / 3).round(2)
        end

        it "applies 2/3 discount for four CF1" do
          %w[CF1 CF1 CF1 CF1].each { |code| checkout.scan(code) }
          expect(checkout.total).to eq(29.95) # (4 * 11.23 * 2.0 / 3).round(2)
        end
      end

      context "combined pricing rules" do
        it "calculates total for GR1, SR1, GR1, GR1, CF1 => £22.45" do
          %w[GR1 SR1 GR1 GR1 CF1].each { |code| checkout.scan(code) }
          expect(checkout.total).to eq(22.45)
        end

        it "calculates total for GR1, GR1 => £3.11 (BOGO)" do
          %w[GR1 GR1].each { |code| checkout.scan(code) }
          expect(checkout.total).to eq(3.11)
        end

        it "calculates total for SR1, SR1, GR1, SR1 => £16.61 (bulk discount)" do
          %w[SR1 SR1 GR1 SR1].each { |code| checkout.scan(code) }
          expect(checkout.total).to eq(16.61)
        end

        it "calculates total for GR1, CF1, SR1, CF1, CF1 => £30.57 (two-thirds discount)" do
          %w[GR1 CF1 SR1 CF1 CF1].each { |code| checkout.scan(code) }
          expect(checkout.total).to eq(30.57)
        end
      end
    end

    context "edge cases" do
      it "handles invalid product code without raising an error" do
        expect { %w[INVALID].each { |code| checkout.scan(code) } }.not_to raise_error
        expect(checkout.total).to eq(0.0)
      end

      it "handles nil product code without raising an error" do
        expect { checkout.scan(nil) }.not_to raise_error
        expect(checkout.total).to eq(0.0)
      end

      it "returns 0.0 when no items are scanned" do
        expect(checkout.total).to eq(0.0)
      end
    end
  end

  describe "#scan" do
    it "returns total amount correctly after scanning GR1, SR1, CF1" do
      %w[GR1 SR1].each { |code| checkout.scan(code) }
      expect(checkout.scan("CF1")).to eq(19.34) # 3.11 + 5.00 + 11.23
    end

    it "returns false when product code is unknown" do
      expect(checkout.scan("INVALID")).to be false
    end

    it "adds a valid product to the cart" do
      expect { %w[GR1].each { |code| checkout.scan(code) } }
        .to change { checkout.cart_items.size }.by(1)
    end

    it "does not add an invalid product to the cart" do
      expect { %w[INVALID].each { |code| checkout.scan(code) } }
        .not_to change { checkout.cart_items.size }
    end
  end
end