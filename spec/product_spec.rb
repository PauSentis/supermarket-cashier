require "spec_helper"

RSpec.describe Product do
  describe "#initialize" do
    it "sets code, name, and price" do
      product = described_class.new("GR1", "Green Tea", 3.11)
      expect(product.code).to eq("GR1")
      expect(product.name).to eq("Green Tea")
      expect(product.price).to eq(3.11)
    end
  end

  describe "#base_price" do
    it "returns the product price" do
      product = described_class.new("GR1", "Green Tea", 3.11)
      expect(product.base_price).to eq(3.11)
    end
  end

  describe ".all" do
    let(:yaml_data) do
      {
        "products" => [
          { "code" => "GR1", "name" => "Green Tea", "price" => 3.11 },
          { "code" => "SR1", "name" => "Strawberries", "price" => 5.00 },
          { "code" => "CF1", "name" => "Coffee", "price" => 11.23 }
        ]
      }
    end

    before do
      allow(YAML).to receive(:load_file).with(Product::PRODUCTS_PATH).and_return(yaml_data)
    end

    it "loads products from YAML" do
      products = described_class.all
      expect(products.size).to eq(3)
      expect(products[0]).to have_attributes(code: "GR1", name: "Green Tea", price: 3.11)
      expect(products[1]).to have_attributes(code: "SR1", name: "Strawberries", price: 5.00)
      expect(products[2]).to have_attributes(code: "CF1", name: "Coffee", price: 11.23)
    end

    it "caches products" do
      described_class.all(reload: true)
      expect(YAML).to have_received(:load_file).once
      described_class.all # Second call should use cache
      expect(YAML).to have_received(:load_file).once
    end
  end

  describe ".find_by_code" do
    before do
      allow(described_class).to receive(:all).and_return([
        described_class.new("GR1", "Green Tea", 3.11),
        described_class.new("SR1", "Strawberries", 5.00)
      ])
    end

    it "returns product matching the code" do
      product = described_class.find_by_code("GR1")
      expect(product).to have_attributes(code: "GR1", name: "Green Tea", price: 3.11)
    end

    it "returns nil for unknown code" do
      expect(described_class.find_by_code("INVALID")).to be_nil
    end
  end
end