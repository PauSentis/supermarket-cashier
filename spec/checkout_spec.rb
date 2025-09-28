require "spec_helper"

RSpec.describe Checkout do
  let(:pricing_rules) { [] }
  let(:checkout) { described_class.new(pricing_rules) }

  it "calculates total for GR1, SR1, GR1, GR1, CF1 => £22.45" do
    %w[GR1 SR1 GR1 GR1 CF1].each { |code| checkout.scan(code) }
    expect(checkout.total).to eq(22.45)
  end

  it "calculates total for GR1, GR1 => £3.11" do
    %w[GR1 GR1].each { |code| checkout.scan(code) }
    expect(checkout.total).to eq(3.11)
  end

  it "calculates total for SR1, SR1, GR1, SR1 => £16.61" do
    %w[SR1 SR1 GR1 SR1].each { |code| checkout.scan(code) }
    expect(checkout.total).to eq(16.61)
  end

  it "calculates total for GR1, CF1, SR1, CF1, CF1 => £30.57" do
    %w[GR1 CF1 SR1 CF1 CF1].each { |code| checkout.scan(code) }
    expect(checkout.total).to eq(30.57)
  end
end