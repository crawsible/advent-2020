#!/usr/bin/env ruby

class Calc
  def evaluate_expression(expression)
    expression = expression.strip().delete(' ')

    until expression.match(/\A\d+\z/)
      if expression.include?("(")
        open, close = matching_parens(expression)
        paren_value = evaluate_expression(expression[open+1..close-1])
        expression = expression.gsub(expression[open..close], paren_value)
      else
        expression = evaluate_simple_expression(expression)
      end
    end

    expression
  end

  protected
  def matching_parens(expression)
    open = expression.rindex('(')
    close = open + expression[open...].index(')')
    [open, close]
  end

  def evaluate_simple_expression(expression)
    value = expression.match(/\A(\d+)/)[1]
    expression = expression[value.length...]
    value = value.to_i

    until expression.empty?
      operator, operand = expression.match(/\A([+*])(\d+)/).captures
      expression = expression[operand.length+1...]

      case operator
      when '+'
        value += operand.to_i
      when '*'
        value *= operand.to_i
      end
    end

    value.to_s
  end
end

calc = Calc.new
result = File.open('data_math_hw.txt').sum do |line|
  calc.evaluate_expression(line).to_i
end

puts result
