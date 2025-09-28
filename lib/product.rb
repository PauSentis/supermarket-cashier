# frozen_string_literal: true

require 'yaml'

class Product
  attr_reader :code, :name, :price

  PRODUCTS_PATH = File.join(File.dirname(__FILE__), '..', 'config', 'products.yml')

  def initialize(code, name, price)
    @code = code
    @name = name
    @price = price
  end

  def base_price = price

  def self.all(reload: false)
    @all = nil if reload
    @all ||= begin
      data = YAML.load_file(PRODUCTS_PATH)
      data['products'].map do |item|
        new(item['code'], item['name'], item['price'])
      end
    end
  end

  def self.find_by_code(item_code)
    all.find { |product| product.code == item_code }
  end
end
