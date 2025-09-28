# Supermarket Checkout System

A Ruby-based checkout system for a supermarket, designed to scan products interactively, apply pricing rules, and generate a ticket with itemized prices and totals. Products and pricing rules are configured via YAML files for easy extensibility.

## Features
- **Interactive CLI**: Scan products, view running totals, and generate a ticket with item details (code, name, quantity, price).
- **Product Catalog**: Displays available products (code, name, price) on startup.
- **Pricing Rules**:
  - Buy One Get One Free (BOGO) for Green Tea (`GR1`).
  - Bulk discount for Strawberries (`SR1`) when buying 3 or more (price drops to £4.50).
  - Two-thirds price discount for Coffee (`CF1`) when buying 3 or more.
- **Configuration**: Products and rules loaded from `config/products.yml` and `config/pricing_rules.yml`.
- **Cart Management**: Tracks item quantities and applies discounts dynamically.
- **Total Calculation**: Rounds totals to two decimal places for currency precision.
- **Testing**: Comprehensive RSpec tests for all components.

## Installation
You can run the checkout system either **locally** on your machine or in a **Docker container**. Docker is recommended as it provides a safer, isolated environment, ensuring consistent Ruby versioning and dependency management across systems.

### Option 1: Run Locally
1. **Prerequisites**:
   - Ruby 3.4.0+ installed (check with `ruby -v`).
   - Bundler installed (`gem install bundler`).
2. Clone the repository:
   ```bash
   git clone <repository_url>
   cd checkout-system
   ```
3. Install dependencies:
   ```bash
   bundle install
   ```
   - Dependencies: `yaml` (standard library), `rspec` (for testing).
4. Ensure configuration files exist in `config/`:
   - `products.yml`: Defines products (code, name, price).
   - `pricing_rules.yml`: Defines discount rules.
   - See **Configuration** section for examples.
5. Run the CLI:
   ```bash
   ruby cli.rb
   ```

### Option 2: Run in Docker (Recommended)
Docker provides a safer, isolated environment with consistent Ruby version (3.4.0) and dependencies, avoiding conflicts with your local system.

1. **Prerequisites**:
   - Docker installed (check with `docker --version`).
2. Clone the repository:
   ```bash
   git clone <repository_url>
   cd checkout-system
   ```
3. Build the Docker image:
   ```bash
   docker build -t checkout-system .
   ```
4. Run the container in interactive mode:
   ```bash
   docker run -it checkout-system
   ```
   - The `-it` flag enables interactive input for the CLI.
   - This executes `ruby cli.rb` as specified in the `Dockerfile`.

## Usage
### Interactive CLI
Run the CLI to start an interactive session:
```bash
ruby cli.rb
```

Example interaction:
```
=== Supermarket Checkout ===
Available Products:
- GR1: Green Tea (£3.11)
- SR1: Strawberries (£5.00)
- CF1: Coffee (£11.23)

Enter product code to scan (or 'done' to finish, 'help' for instructions):
Scan: GR1
Scanned: GR1
Current Total: £3.11
Scan: SR1
Scanned: SR1
Current Total: £8.11
Scan: done

=== Checkout Ticket ===
Items:
- GR1: Green Tea x1 @ £3.11 = £3.11
- SR1: Strawberries x1 @ £5.00 = £5.00
Total: £8.11
====================
```

Use `--help` for instructions:
```bash
ruby cli.rb --help
```

### In IRB
For development or testing:
```bash
irb
```
```ruby
require './lib/checkout'
co = Checkout.new
co.scan("GR1")
co.scan("GR1")
puts co.total # => 3.11 (BOGO applied)
```

### Adding New Pricing Rules
1. Create a new rule in `lib/pricing_rules/` (e.g., `new_rule.rb`):
   ```ruby
   module PricingRules
     class NewRule < ::PricingRule
       def apply(cart_items)
         # Implement discount logic
       end
     end
   end
   ```
2. Add to `config/pricing_rules.yml`:
   ```yaml
   rules:
     - type: NewRule
       product_code: XYZ
       # Other parameters
   ```

## Configuration
- **Products** (`config/products.yml`):
  ```yaml
  products:
    - code: GR1
      name: Green Tea
      price: 3.11
    - code: SR1
      name: Strawberries
      price: 5.00
    - code: CF1
      name: Coffee
      price: 11.23
  ```
- **Pricing Rules** (`config/pricing_rules.yml`):
  ```yaml
  rules:
    - type: BogoRule
      product_code: GR1
    - type: BulkDiscountRule
      product_code: SR1
      min_quantity: 3
      new_price: 4.50
    - type: TwoThirdsRule
      product_code: CF1
      min_quantity: 3
  ```

## Testing
Run all tests:
```bash
bundle exec rspec
# or in Docker:
docker run -it checkout-system bundle exec rspec
```
- Specs cover: `Product`, `CartItem`, `PricingRule`, individual rules (`BogoRule`, `BulkDiscountRule`, `TwoThirdsRule`), and `Checkout`.
- Tests mock YAML files for isolation.

## Project Structure
- `lib/`: Core classes (`checkout.rb`, `product.rb`, `cart_item.rb`, `pricing_rule.rb`).
- `lib/pricing_rules/`: Discount rule subclasses (dynamically loaded).
- `config/`: YAML configuration files (`products.yml`, `pricing_rules.yml`).
- `spec/`: RSpec tests for all components.
- `cli.rb`: Interactive CLI entry point.
- `Dockerfile`: Defines container setup for Ruby 3.4.0.
