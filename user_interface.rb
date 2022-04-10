# frozen_string_literal: true

require_relative 'code_unlocker'

module UserInterface
  def self.run
    puts('Enter initial combination numbers divided by comma:')
    initial_combination = convert_to_array(gets.chomp) { |a| a.map(&:to_i) }

    puts('Enter final combination numbers divided by comma:')
    final_combination = convert_to_array(gets.chomp) { |a| a.map(&:to_i) }

    unless initial_combination.size == final_combination.size
      return puts('ERROR: Initial combination should have the same size` as final combination')
    end

    if initial_combination.size < 2 || final_combination.size < 2
      return puts('ERROR: Initial combination and final combination should both have greater than 2 numbers')
    end

    puts('Enter restricted combinations divided by vertical line (example: 1,2,3,4 | 2,4,5,3):')
    restricted_combinations =
      convert_to_array(gets.chomp, separator: '|').map { |el| convert_to_array(el) { |a| a.map(&:to_i) } }

    return puts('ERROR: All restricted combinations should be array type') unless restricted_combinations.all?(Array)

    if restricted_combinations.any? { |array| array.size != initial_combination.size }
      return puts('ERROR: All restricted combinations should be the same size with initial or final combination')
    end

    puts 'Result:'
    CodeUnlocker.run(initial_combination, final_combination, restricted_combinations: restricted_combinations)
  end

  def self.convert_to_array(string, separator: ',', &block)
    array = string.split(separator).map(&:strip)
    block ? yield(array) : array
  end
end

UserInterface.run
