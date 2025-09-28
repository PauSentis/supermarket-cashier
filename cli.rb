#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/checkout'

# Command-line interface for the supermarket checkout
class CLI
  def initialize
    @checkout = Checkout.new
  end

  # Run the CLI in interactive mode or show help
  def run(args)
    if args.include?('--help') || args.include?('-h')
      print_help
      return
    end

    run_interactive
  rescue Errno::ENOENT => e
    puts "Error: Configuration file missing (#{e.message}). Ensure config/products.yml and config/pricing_rules.yml exist."
    exit(1)
  rescue StandardError => e
    puts "Error: #{e.message}"
    exit(1)
  end

  private

  def run_interactive
    puts '=== Supermarket Checkout ==='
    print_products
    puts "\nEnter product code to scan (or 'done' to finish, 'help' for instructions):"

    loop do
      print 'Scan: '
      input = gets.chomp.strip.upcase
      break if input == 'DONE'

      if input == 'HELP'
        print_help
        next
      end

      if scan_item(input)
        puts "Scanned: #{input}"
        print_current_total
      else
        puts "Invalid code: #{input}. Valid codes: #{Product.all.map(&:code).join(', ')}"
      end
    end

    print_ticket
  end

  def scan_item(code)
    return false unless code.is_a?(String) && !code.empty?

    @checkout.scan(code)
  end

  def print_products
    puts 'Available Products:'
    Product.all.each do |product|
      puts "- #{product.code}: #{product.name} (£#{format('%.2f', product.price)})"
    end
  end

  def print_current_total
    puts "Current Total: £#{format('%.2f', @checkout.total)}"
  end

  def print_ticket
    return puts 'No items scanned.' if @checkout.cart_items.empty?

    puts "\n=== Checkout Ticket ==="
    puts 'Items:'
    @checkout.cart_items.each do |item|
      puts "- #{item.code}: #{item.name} x#{item.quantity} @ £#{format('%.2f',
                                                                       item.unit_price)} = £#{format('%.2f',
                                                                                                     item.total_amount)}"
    end
    puts "Total: £#{format('%.2f', @checkout.total)}"
    puts '===================='
  end

  # Print help message
  def print_help
    puts <<~HELP
      Supermarket Checkout CLI (Interactive Mode)
      Usage:
        ruby cli.rb         # Start interactive mode
        ruby cli.rb --help  # Show this help

      Instructions:
        - Enter a product code (e.g., GR1) to scan an item.
        - Enter 'done' to finish and see the ticket.
        - Enter 'help' to see these instructions.
        - Pricing rules (e.g., BOGO, bulk discounts) are applied automatically.

      Valid product codes: #{Product.all.map(&:code).join(', ')}
    HELP
  end
end

# Run CLI with command-line arguments
CLI.new.run(ARGV)
