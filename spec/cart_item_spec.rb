# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CartItem do
  let(:product) { Product.new('GR1', 'Green Tea', 3.11) }

  describe '#initialize' do
    it 'sets product, quantity, and unit_price' do
      item = described_class.new(product)
      expect(item.product).to eq(product)
      expect(item.quantity).to eq(1)
      expect(item.unit_price).to eq(3.11)
    end
  end

  describe '#increment' do
    it 'increases quantity by 1' do
      item = described_class.new(product)
      expect { item.increment }.to change { item.quantity }.from(1).to(2)
    end
  end

  describe '#total_amount' do
    it 'calculates unit_price * quantity' do
      item = described_class.new(product)
      item.unit_price = 3.00
      item.increment # quantity = 2
      expect(item.total_amount).to eq(6.00) # 3.00 * 2
    end
  end

  describe 'delegated methods' do
    let(:item) { described_class.new(product) }

    it 'delegates code to product' do
      expect(item.code).to eq('GR1')
    end

    it 'delegates name to product' do
      expect(item.name).to eq('Green Tea')
    end

    it 'delegates base_price to product' do
      expect(item.base_price).to eq(3.11)
    end
  end
end
