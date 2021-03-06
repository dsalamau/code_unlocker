# frozen_string_literal: true

### Example:
### CodeUnlocker.run([1, 5, 2, 8, 2, 9], [9, 6, 5, 2, 0, 4], restricted_combinations: [[9, 6, 5, 2, 3, 9], [9, 6, 5, 2, 6, 9]])

module CodeUnlocker
  DIGITS = (0..9).to_a

  NEXT_INDEX = lambda do |current_index, combination|
    return 0 if combination.count - 1 == current_index

    current_index + 1
  end

  NEXT_NUMBER = lambda do |current_number|
    return DIGITS.first if DIGITS.last == current_number

    DIGITS[DIGITS.find_index(current_number) + 1]
  end

  PREVIOUS_NUMBER = lambda do |current_number|
    return DIGITS.last if DIGITS.first == current_number

    DIGITS[DIGITS.find_index(current_number) - 1]
  end

  def self.run(start_combination, result_combination, restricted_combinations: [], **kwargs)
    combinations_list = kwargs[:combinations_list] || [start_combination]
    return pp(*combinations_list) if start_combination == result_combination

    current_combination = start_combination.dup
    current_number_index = kwargs[:current_number_index] || 0

    short_direction =
      find_direction(current_combination[current_number_index], result_combination[current_number_index])
    direction = kwargs[:direction] || short_direction

    current_combination[current_number_index] =
      Object.const_get("CodeUnlocker::#{direction}").call(current_combination[current_number_index])

    if restricted_combinations.include?(current_combination)
      current_combination[current_number_index] = start_combination[current_number_index]

      options = if direction == short_direction
                  next_index = NEXT_INDEX.call(current_number_index, current_combination)
                  { current_number_index: next_index, single_switch: true }
                else
                  { current_number_index: current_number_index, direction: opposite_direction(direction) }
                end

      run(
        current_combination,
        result_combination,
        restricted_combinations: restricted_combinations,
        combinations_list: combinations_list,
        **options
      )

      return
    end

    combinations_list << current_combination

    is_correct_number = current_combination[current_number_index] == result_combination[current_number_index]
    options = if is_correct_number || kwargs[:single_switch]
                { current_number_index: NEXT_INDEX.call(current_number_index, current_combination) }
              else
                { current_number_index: current_number_index, direction: direction }
              end

    run(
      current_combination,
      result_combination,
      restricted_combinations: restricted_combinations,
      combinations_list: combinations_list,
      **options
    )
  rescue SystemStackError
    message = "COMBINATIONS LIST FROM #{combinations_list[0]} TO #{result_combination} IS MISSING." \
              "RESTRICTED COMBINATIONS: #{restricted_combinations}."
    puts(message)
  end

  def self.find_direction(start_number, final_number)
    next_numbers = [start_number]
    (DIGITS.count / 2).times { next_numbers << NEXT_NUMBER.call(next_numbers.last) }
    next_numbers.include?(final_number) ? 'NEXT_NUMBER' : 'PREVIOUS_NUMBER'
  end

  def self.opposite_direction(direction)
    case direction
    when 'NEXT_NUMBER' then 'PREVIOUS_NUMBER'
    when 'PREVIOUS_NUMBER' then 'NEXT_NUMBER'
    end
  end
end
