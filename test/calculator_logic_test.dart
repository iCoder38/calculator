import 'package:calculator/Classes/Logic/logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CalculatorLogic calculator;
  setUp(() => calculator = CalculatorLogic());

  test('arithmetic respects operator precedence and parentheses', () {
    expect(calculator.evaluateExpression('2+3*4'), '14');
    expect(calculator.evaluateExpression('(2+3)*4'), '20');
  });

  test('scientific functions and percentages return expected values', () {
    expect(calculator.evaluateExpression('√(81)'), '9');
    expect(calculator.evaluateExpression('log10(100)'), '2');
    expect(calculator.evaluateExpression('5!'), '120');
    expect(calculator.evaluateExpression('50%'), '0.5');
  });

  test('invalid expressions are handled without crashing', () {
    expect(calculator.evaluateExpression('2+'), 'Error');
  });

  test('clear and backspace reset calculator input', () {
    expect(calculator.processInput('C', '123'), '0');
    expect(calculator.processInput('⌫', '123'), '12');
    expect(calculator.processInput('⌫', ''), '0');
  });
}
