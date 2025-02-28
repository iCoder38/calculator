import 'dart:math';
import 'package:math_expressions/math_expressions.dart';

class CalculatorLogic {
  double memory = 0.0;

  String processInput(String label, String currentResult) {
    if (currentResult == '0' && _isNumericOrFunction(label)) {
      currentResult = ''; // ✅ Ensure `0` is removed when starting new input
    }

    switch (label) {
      case 'C':
        return '0';
      case '⌫':
        return currentResult.isEmpty || currentResult == '0'
            ? '0'
            : currentResult.substring(0, currentResult.length - 1);
      case 'π':
        return currentResult == '0' ? 'π' : '$currentResultπ';
      case 'e':
        return currentResult == '0' ? 'e' : '${currentResult}e';

      // ✅ Ensure `sin(`, `cos(`, `tan(` start fresh (remove default "0")
      case 'sin':
      case 'cos':
      case 'tan':
      case 'sin⁻¹':
      case 'cos⁻¹':
      case 'tan⁻¹':
      case 'sinh':
      case 'cosh':
      case 'tanh':
      case 'ln':
      case '√':
      case '∛':
      case 'eⁿ':
        return '${currentResult == '0' ? '' : currentResult}$label(';
      case 'x²':
        return '$currentResult^2';
      case 'x³':
        return '$currentResult^3';
      case 'x⁻¹':
        return '$currentResult^(-1)';
      case 'xⁿ':
        return '$currentResult^';
      case 'x!':
        return '$currentResult!';
      case 'log₁₀':
        return '${currentResult == '0' ? '' : currentResult}log10(';
      case '(':
      case ')':
        return currentResult + label;
      case '÷':
        return '$currentResult/';
      case '×':
        return '$currentResult*';
      case '−':
        return '$currentResult-';
      case '+':
        return '$currentResult+';

      default:
        return currentResult == '0' ? label : currentResult + label;
    }
  }

  bool _isNumericOrFunction(String label) {
    return RegExp(r'^[0-9πesincostanlog√∛!%()÷×−+.]$').hasMatch(label);
  }

  String evaluateExpression(String expression) {
    String expr = expression
        .replaceAll('π', pi.toString())
        .replaceAll('e', e.toString());

    // ✅ Handle percentages
    expr = expr.replaceAllMapped(RegExp(r'(\d+\.?\d*)%'), (match) {
      double number = double.parse(match.group(1)!);
      return (number / 100).toString();
    });

    // ✅ Handle factorial
    expr = expr.replaceAllMapped(RegExp(r'(\d+)!'), (match) {
      int number = int.parse(match.group(1)!);
      int factorial = 1;
      for (int i = 2; i <= number; i++) {
        factorial *= i;
      }
      return factorial.toString();
    });

    // ✅ Convert `√(x)` to `sqrt(x)`
    expr = expr.replaceAllMapped(RegExp(r'√\(([^)]+)\)'), (match) {
      double num = _evaluateSimpleExpression(match.group(1)!);
      return num < 0 ? 'Error' : sqrt(num).toString();
    });

    // ✅ Convert `∛(x)` to `cbrt(x)`
    expr = expr.replaceAllMapped(RegExp(r'∛\(([^)]+)\)'), (match) {
      double num = _evaluateSimpleExpression(match.group(1)!);
      double result = pow(num, 1 / 3).toDouble();
      return result % 1 == 0
          ? result.toInt().toString()
          : result.toStringAsFixed(6);
    });

    // ✅ Convert `log10(x)` to `log(x) / log(10)`
    expr = expr.replaceAllMapped(RegExp(r'log10\(([^)]+)\)'), (match) {
      double? num =
          double.tryParse(match.group(1)!) ??
          _evaluateSimpleExpression(match.group(1)!);
      return (num > 0) ? (log(num) / log(10)).toString() : 'Error';
    });

    // ✅ Convert `ln(x)` to `log(x) / log(e)`
    expr = expr.replaceAllMapped(RegExp(r'ln\(([^)]+)\)'), (match) {
      double num = _evaluateSimpleExpression(match.group(1)!);
      return num <= 0 ? 'Error' : (log(num) / log(e)).toString();
    });

    // ✅ Convert trigonometric functions from degrees to radians before parsing
    expr = expr.replaceAllMapped(RegExp(r'sin\(([^)]+)\)'), (match) {
      double num = _evaluateSimpleExpression(match.group(1)!);
      return sin(num * (pi / 180)).toString();
    });

    expr = expr.replaceAllMapped(RegExp(r'cos\(([^)]+)\)'), (match) {
      double num = _evaluateSimpleExpression(match.group(1)!);
      return cos(num * (pi / 180)).toString();
    });

    expr = expr.replaceAllMapped(RegExp(r'tan\(([^)]+)\)'), (match) {
      double num = _evaluateSimpleExpression(match.group(1)!);
      return tan(num * (pi / 180)).toString();
    });

    // ✅ Convert hyperbolic functions properly (using radian values)
    expr = expr.replaceAllMapped(RegExp(r'sinh\(([^)]+)\)'), (match) {
      double num = _evaluateSimpleExpression(match.group(1)!);
      return _sinh(num * (pi / 180)).toString();
    });

    expr = expr.replaceAllMapped(RegExp(r'cosh\(([^)]+)\)'), (match) {
      double num = _evaluateSimpleExpression(match.group(1)!);
      return _cosh(num * (pi / 180)).toString();
    });

    expr = expr.replaceAllMapped(RegExp(r'tanh\(([^)]+)\)'), (match) {
      double num = _evaluateSimpleExpression(match.group(1)!);
      return _tanh(num * (pi / 180)).toString();
    });

    // ✅ Convert radians to degrees for inverse trig functions
    expr = expr.replaceAllMapped(RegExp(r'asin\(([^)]+)\)'), (match) {
      double num = _evaluateSimpleExpression(match.group(1)!);
      return (asin(num) * (180 / pi)).toString();
    });

    expr = expr.replaceAllMapped(RegExp(r'acos\(([^)]+)\)'), (match) {
      double num = _evaluateSimpleExpression(match.group(1)!);
      return (acos(num) * (180 / pi)).toString();
    });

    expr = expr.replaceAllMapped(RegExp(r'atan\(([^)]+)\)'), (match) {
      double num = _evaluateSimpleExpression(match.group(1)!);
      return (atan(num) * (180 / pi)).toString();
    });

    // ✅ Handle `e^x` as `exp(x)`
    expr = expr.replaceAllMapped(RegExp(r'e\^([0-9.]+)'), (match) {
      double num = double.parse(match.group(1)!);
      return exp(num).toString();
    });

    // ✅ Convert `x⁻¹` (reciprocal) to `1/x` and prevent division by zero
    expr = expr.replaceAllMapped(RegExp(r'(\d+|\([^)]*\))\^\(-1\)'), (match) {
      double num = _evaluateSimpleExpression(match.group(1)!);
      return (num != 0)
          ? (1 / num).toString()
          : 'Error'; // ❌ Prevents division by zero
    });

    try {
      Parser p = Parser();
      Expression exp = p.parse(expr);
      ContextModel cm = ContextModel();

      double evalResult = exp.evaluate(EvaluationType.REAL, cm);
      return evalResult % 1 == 0
          ? evalResult.toInt().toString()
          : evalResult.toString();
    } catch (e) {
      return 'Error';
    }
  }

  /// ✅ Helper function to evaluate simple expressions inside `log10()`, `ln()`, etc.
  double _evaluateSimpleExpression(String expression) {
    try {
      Parser p = Parser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      return exp.evaluate(EvaluationType.REAL, cm);
    } catch (e) {
      return double.nan;
    }
  }

  /// ✅ Manually defined hyperbolic functions
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
