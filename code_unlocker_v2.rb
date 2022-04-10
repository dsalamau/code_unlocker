# frozen_string_literal: true

require 'pry'

module CodeUnlocker
  class UnableToFindCombinationError < StandardError; end

  DIGITS = (0..9).to_a

  NEXT_INDEX = lambda do |current_index, combination|
    return 0 if combination.count - 1 == current_index

    current_index + 1
  end

  PREVIOUS_INDEX = lambda do |current_index, combination|
    return combination.count - 1 if (current_index - 1).negative?

    current_index - 1
  end

  NEXT_NUMBER = lambda do |current_number|
    return DIGITS.first if DIGITS.last == current_number

    DIGITS[DIGITS.find_index(current_number) + 1]
  end

  PREVIOUS_NUMBER = lambda do |current_number|
    return DIGITS.last if DIGITS.first == current_number

    DIGITS[DIGITS.find_index(current_number) - 1]
  end

  def self.find_combination(start_combination, result_combination, exclude_combinations: [[2, 1, 1], [1, 1, 0], [1, 0, 1], [0, 1, 1]], **kwargs)
    combinations = kwargs[:combinations] || [start_combination]
    return pp(*combinations) if start_combination == result_combination

    current_number_index = kwargs[:current_number_index] || 0
    current_combination = start_combination.dup

    current_combination[current_number_index] = if kwargs[:single_switch]
                                                  PREVIOUS_NUMBER.(current_combination[current_number_index])
                                                else
                                                  NEXT_NUMBER.(current_combination[current_number_index])
                                                end

    if exclude_combinations.include?(current_combination)
      current_combination[current_number_index] = start_combination[current_number_index]

      find_combination(
        current_combination,
        result_combination,
        exclude_combinations: exclude_combinations,
        combinations: combinations,
        current_number_index: PREVIOUS_INDEX.(current_number_index, current_combination),
        single_switch: true,
      )
    elsif (current_combination[current_number_index] == result_combination[current_number_index]) || kwargs[:single_switch]
      combinations << current_combination

      find_combination(
        current_combination,
        result_combination,
        exclude_combinations: exclude_combinations,
        combinations: combinations,
        current_number_index: NEXT_INDEX.(current_number_index, current_combination),
      )
    else
      combinations << current_combination

      find_combination(
        current_combination,
        result_combination,
        exclude_combinations: exclude_combinations,
        combinations: combinations,
        current_number_index: current_number_index,
      )
    end

    rescue SystemStackError
      raise UnableToFindCombinationError.new('Possibly unable to find a combination')
  end

  def self.switch_number(current_number, final_number)
    current_number_index = DIGITS.find_index(current_number)
    final_number_index = DIGITS.find_index(final_number)
    middle_number_index = current_number_index + DIGITS.count / 2
    increase_operator = final_number_index.between?(current_number_index, middle_number_index)
    increase_operator ? NEXT_NUMBER.(current_number) : PREVIOUS_NUMBER.(current_number)
  end
end

CodeUnlocker.find_combination([1, 1, 1], [2, 2, 2])
