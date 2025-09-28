class CartItem
  attr_reader :product, :quantity
  attr_accessor :unit_price

  def initialize(product)
    @product = product
    @quantity = 1
    self.unit_price = base_price # can be modified later by pricing rules
  end

  def increment
    @quantity += 1
  end

  def total_amount = unit_price * quantity

  [:code, :name, :base_price].each do |method|
    define_method(method) { product.public_send(method) }
  end
end
