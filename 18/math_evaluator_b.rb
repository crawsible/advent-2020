#!/usr/bin/env ruby

class Calc
  def evaluate_expression(expression)
    expression = expression.strip().delete(' ')

    until expression.match(/\A\d+\z/)
      if expression.include?("(")
        expression = resolve_parens(expression)
      elsif expression.include?('+')
        expression = resolve_operation(expression, '+')
      else
        expression = resolve_operation(expression, '*')
      end
    end

    expression
  end

  private
  def resolve_parens(expression)
    open = expression.rindex('(')
    close = open + expression[open...].index(')')

    paren_value = evaluate_expression(expression[open+1..close-1])
    expression.gsub(expression[open..close], paren_value)
  end

  def resolve_operation(expression, operator)
    operand0, operand1 = expression.match(/(\d+)[#{operator}](\d+)/).captures

    result = operand0.to_i.send(operator.to_sym, operand1.to_i)

    operator_index = expression.index(operator)
    open = operator_index - operand0.length
    close = operator_index + operand1.length

    expression.sub(expression[open..close], result.to_s)
  end
end

calc = Calc.new
result = File.open('data_math_hw.txt').sum do |line|
  calc.evaluate_expression(line).to_i
end

puts result
