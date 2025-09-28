# frozen_string_literal: true

require 'yaml'

class PricingRule
  attr_reader :options

  PRICING_RULES_PATH = File.join(File.dirname(__FILE__), '..', 'config', 'pricing_rules.yml')

  def initialize(options)
    @options = options
  end

  def self.all(reload: false)
    @all = nil if reload
    @all ||= begin
      data = YAML.load_file(PRICING_RULES_PATH)
      data['rules'].map do |rule_hash|
        type = rule_hash['type']

        raise NameError, "Unknown rule type: #{type}" unless PricingRules.const_defined?(type)

        klass = PricingRules.const_get(type)
        klass.new(rule_hash)
      end
    end
  end

  def apply(_cart_items)
    raise NotImplementedError, 'Each rule must implement #apply'
  end
end

# Load pricing rule subclasses after PricingRule is defined
Dir[File.join(__dir__, 'pricing_rules', '*.rb')].each { |f| require f }
