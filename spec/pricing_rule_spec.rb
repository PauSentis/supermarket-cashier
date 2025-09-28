# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PricingRule do
  describe '#initialize' do
    it 'sets options' do
      rule = described_class.new('type' => 'TestRule', 'product_code' => 'GR1')
      expect(rule.options).to eq('type' => 'TestRule', 'product_code' => 'GR1')
    end
  end

  describe '#apply' do
    it 'raises NotImplementedError' do
      rule = described_class.new('type' => 'TestRule')
      expect { rule.apply([]) }.to raise_error(NotImplementedError, 'Each rule must implement #apply')
    end
  end

  describe '.all' do
    let(:yaml_data) do
      {
        'rules' => [
          { 'type' => 'BogoRule', 'product_code' => 'GR1' },
          { 'type' => 'BulkDiscountRule', 'product_code' => 'SR1', 'min_quantity' => 3, 'new_price' => 4.50 },
          { 'type' => 'TwoThirdsRule', 'product_code' => 'CF1', 'min_quantity' => 3 }
        ]
      }
    end

    before do
      allow(YAML).to receive(:load_file).with(PricingRule::PRICING_RULES_PATH).and_return(yaml_data)
    end

    it 'loads rules from YAML and instantiates correct classes' do
      rules = described_class.all
      expect(rules.size).to eq(3)
      expect(rules[0]).to be_a(PricingRules::BogoRule)
      expect(rules[0].options).to eq('type' => 'BogoRule', 'product_code' => 'GR1')
      expect(rules[1]).to be_a(PricingRules::BulkDiscountRule)
      expect(rules[2]).to be_a(PricingRules::TwoThirdsRule)
    end

    it 'caches rules' do
      described_class.all(reload: true)
      expect(YAML).to have_received(:load_file).once
      described_class.all
      expect(YAML).to have_received(:load_file).once
    end

    context 'when rule type is unknown' do
      let(:yaml_data) do
        { 'rules' => [{ 'type' => 'UnknownRule', 'product_code' => 'GR1' }] }
      end

      it 'raises NameError' do
        expect { described_class.all(reload: true) }.to raise_error(NameError, 'Unknown rule type: UnknownRule')
      end
    end
  end
end
