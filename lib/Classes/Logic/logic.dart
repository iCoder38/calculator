import 'dart:math';
import 'package:math_expressions/math_expressions.dart';

class CalculatorLogic {
  String processInput(String input, String currentResult) {
    try {
      switch (input) {
        case 'C':
          return '0';
        case '⌫':
          return currentResult.length > 1
              ? currentResult.substring(0, currentResult.length - 1)
              : '0';
        case '=':
          return _evaluateExpression(currentResult);
        case 'π':
          return currentResult + pi.toString();
        case 'e':
          return currentResult + e.toString();
        case '√':
          return _evaluateExpression('sqrt($currentResult)');
        case '∛':
          return _evaluateExpression('pow($currentResult,1/3)');
        case 'x²':
          return _evaluateExpression('pow($currentResult,2)');
        case 'x³':
          return _evaluateExpression('pow($currentResult,3)');
        case 'x⁻¹':
          return _evaluateExpression('1/($currentResult)');
        case 'x!':
          return _factorial(int.parse(currentResult)).toString();
        case 'sin':
          return _evaluateExpression('sin(${_toRadians(currentResult)})');
        case 'cos':
          return _evaluateExpression('cos(${_toRadians(currentResult)})');
        case 'tan':
          return _evaluateExpression('tan(${_toRadians(currentResult)})');
        case 'sinh':
          return _sinh(double.parse(currentResult)).toString();
        case 'cosh':
          return _cosh(double.parse(currentResult)).toString();
        case 'tanh':
          return _tanh(double.parse(currentResult)).toString();
        case 'ln':
          return _evaluateExpression('ln($currentResult)');
        case 'log₁₀':
          return _evaluateExpression('log10($currentResult)');
        case '%':
          return _evaluateExpression('($currentResult)/100');
        default:
          return currentResult == '0' ? input : currentResult + input;
      }
    } catch (e) {
      return 'Error';
    }
  }

  /// Evaluates expressions using `math_expressions` package
  String _evaluateExpression(String expression) {
    try {
      // Replace symbols with Dart-compatible expressions
      expression = expression.replaceAll('÷', '/').replaceAll('×', '*');

      Parser parser = Parser();
      Expression exp = parser.parse(expression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      return eval.toString();
    } catch (e) {
      return 'Error';
    }
  }

  /// Converts degrees to radians
  double _toRadians(String value) {
    return double.parse(value) * (pi / 180);
  }

  /// Factorial function
  int _factorial(int num) {
    if (num <= 1) return 1;
    return num * _factorial(num - 1);
  }

  /// Hyperbolic functions
  double _sinh(double x) {
    return (exp(x) - exp(-x)) / 2;
  }

  double _cosh(double x) {
    return (exp(x) + exp(-x)) / 2;
  }

  double _tanh(double x) {
    return _sinh(x) / _cosh(x);
  }
}
