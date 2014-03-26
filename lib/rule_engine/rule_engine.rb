#RuleEngine: Querying, Matching and Notifying

require 'rubygems'
require 'yahoo_stock'

require_relative 'base_rule'

class RuleEngine::RuleEngine
    def initialize
        @rules = {}
        @results = {}
    end

    def start
        # @start_time = Time.now
        puts "%s Engine is on." % @start_time

        #Iterate all rules
        @rules.each do |ticker, raw_trigger|
            rule = BaseRule.new(ticker)
            rule.add_triggers(raw_trigger)
            rule.ready
            @results[ticker] = [rule.is_met?, rule.get_condition]
        end
        puts @results
    end

    def add_fuel ticker, property, rel, target
        @rules[ticker] = {property => [rel, target]}
    end

    def get_results
        @results
    end
end
